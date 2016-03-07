From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Mon, 07 Mar 2016 14:05:22 -0500 (EST)
Message-ID: <20160307.140522.1910222129785231486.davem@davemloft.net>
References: <cover.1456937772.git.sd@queasysnail.net>
	<cover.1456937772.git.sd@queasysnail.net>
	<d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, stephen@networkplumber.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbcCGTFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:05:25 -0500
In-Reply-To: <d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon,  7 Mar 2016 18:12:40 +0100

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f184fb5bd110..2a1ba62b7da2 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -193,6 +193,13 @@ config GENEVE
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called geneve.
>  
> +config MACSEC
> +	tristate "IEEE 802.1AE MAC-level encryption (MACsec)"
> +	select CRYPTO_AES
> +	select CRYPTO_GCM
> +	---help---
> +	   MACsec is an encryption standard for Ethernet.
> +
>  config NETCONSOLE
>  	tristate "Network console logging support"
>  	---help---
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 900b0c5320bb..1aa7cb845663 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_IPVLAN) += ipvlan/
>  obj-$(CONFIG_DUMMY) += dummy.o
>  obj-$(CONFIG_EQUALIZER) += eql.o
>  obj-$(CONFIG_IFB) += ifb.o
> +obj-$(CONFIG_MACSEC) += macsec.o
>  obj-$(CONFIG_MACVLAN) += macvlan.o
>  obj-$(CONFIG_MACVTAP) += macvtap.o
>  obj-$(CONFIG_MII) += mii.o
> diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
> new file mode 100644
> index 000000000000..af79f59d4dd7
> --- /dev/null
> +++ b/drivers/net/macsec.c
> @@ -0,0 +1,3037 @@
> +/*
> + * drivers/net/macsec.c - MACsec device
> + *
> + * Copyright (c) 2015 Sabrina Dubroca <sd@queasysnail.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/skbuff.h>
> +#include <linux/socket.h>
> +#include <linux/module.h>
> +#include <crypto/aead.h>
> +#include <linux/etherdevice.h>
> +#include <linux/rtnetlink.h>
> +#include <net/genetlink.h>
> +#include <net/sock.h>
> +
> +#include <uapi/linux/if_macsec.h>
> +
> +typedef u64 __bitwise sci_t;
> +
> +#define MACSEC_SCI_LEN 8
> +
> +/* SecTAG length = macsec_eth_header without the optional SCI */
> +#define MACSEC_TAG_LEN 6
> +
> +struct macsec_eth_header {
> +	struct ethhdr eth;
> +	/* SecTAG */
> +	u8  tci_an;
> +#if defined(__LITTLE_ENDIAN_BITFIELD)
> +	u8  short_length:6,
> +		  unused:2;
> +#elif defined(__BIG_ENDIAN_BITFIELD)
> +	u8        unused:2,
> +	    short_length:6;
> +#else
> +#error	"Please fix <asm/byteorder.h>"
> +#endif
> +	__be32 packet_number;
> +	u8 secure_channel_id[8]; /* optional */
> +} __packed;
> +
> +#define MACSEC_TCI_VERSION 0x80
> +#define MACSEC_TCI_ES      0x40 /* end station */
> +#define MACSEC_TCI_SC      0x20 /* SCI present */
> +#define MACSEC_TCI_SCB     0x10 /* epon */
> +#define MACSEC_TCI_E       0x08 /* encryption */
> +#define MACSEC_TCI_C       0x04 /* changed text */
> +#define MACSEC_AN_MASK     0x03 /* association number */
> +#define MACSEC_TCI_CONFID  (MACSEC_TCI_E | MACSEC_TCI_C)
> +
> +#define MACSEC_SHORTLEN_THR 48
> +
> +#define GCM_AES_IV_LEN 12
> +#define DEFAULT_ICV_LEN 16
> +
> +#define for_each_rxsc(secy, sc)			\
> +	for (sc = rcu_dereference_bh(secy->rx_sc);	\
> +	     sc;				\
> +	     sc = rcu_dereference_bh(sc->next))
> +#define for_each_rxsc_rtnl(secy, sc)			\
> +	for (sc = rtnl_dereference(secy->rx_sc);	\
> +	     sc;					\
> +	     sc = rtnl_dereference(sc->next))
> +
> +struct gcm_iv {
> +	union {
> +		u8 secure_channel_id[8];
> +		sci_t sci;
> +	};
> +	__be32 pn;
> +};
> +
> +/**
> + * struct macsec_key - SA key
> + * @id user-provided key identifier
> + * @tfm crypto struct, key storage
> + */
> +struct macsec_key {
> +	u64 id;
> +	struct crypto_aead *tfm;
> +};
> +
> +/**
> + * struct macsec_rx_sa - receive secure association
> + * @active
> + * @next_pn packet number expected for the next packet
> + * @lock protects next_pn manipulations
> + * @key key structure
> + * @stats per-SA stats
> + */
> +struct macsec_rx_sa {
> +	bool active;
> +	u32 next_pn;
> +	spinlock_t lock;
> +	struct macsec_key key;
> +	struct macsec_rx_sa_stats __percpu *stats;
> +	struct macsec_rx_sc *sc;
> +	atomic_t refcnt;
> +	struct rcu_head rcu;
> +};
> +
> +struct pcpu_rx_sc_stats {
> +	struct macsec_rx_sc_stats stats;
> +	struct u64_stats_sync syncp;
> +};
> +
> +/**
> + * struct macsec_rx_sc - receive secure channel
> + * @sci secure channel identifier for this SC
> + * @active channel is active
> + * @sa array of secure associations
> + * @stats per-SC stats
> + */
> +struct macsec_rx_sc {
> +	struct macsec_rx_sc __rcu *next;
> +	sci_t sci;
> +	bool active;
> +	struct macsec_rx_sa __rcu *sa[4];
> +	struct pcpu_rx_sc_stats __percpu *stats;
> +	atomic_t refcnt;
> +	struct rcu_head rcu_head;
> +};
> +
> +/**
> + * struct macsec_tx_sa - transmit secure association
> + * @active
> + * @next_pn packet number to use for the next packet
> + * @lock protects next_pn manipulations
> + * @key key structure
> + * @stats per-SA stats
> + */
> +struct macsec_tx_sa {
> +	bool active;
> +	u32 next_pn;
> +	spinlock_t lock;
> +	struct macsec_key key;
> +	struct macsec_tx_sa_stats __percpu *stats;
> +	atomic_t refcnt;
> +	struct rcu_head rcu;
> +};
> +
> +struct pcpu_tx_sc_stats {
> +	struct macsec_tx_sc_stats stats;
> +	struct u64_stats_sync syncp;
> +};
> +
> +/**
> + * struct macsec_tx_sc - transmit secure channel
> + * @active
> + * @encoding_sa association number of the SA currently in use
> + * @encrypt encrypt packets on transmit, or authenticate only
> + * @send_sci always include the SCI in the SecTAG
> + * @end_station
> + * @scb single copy broadcast flag
> + * @sa array of secure associations
> + * @stats stats for this TXSC
> + */
> +struct macsec_tx_sc {
> +	bool active;
> +	u8 encoding_sa;
> +	bool encrypt;
> +	bool send_sci;
> +	bool end_station;
> +	bool scb;
> +	struct macsec_tx_sa __rcu *sa[4];
> +	struct pcpu_tx_sc_stats __percpu *stats;
> +};
> +
> +#define MACSEC_VALIDATE_DEFAULT MACSEC_VALIDATE_STRICT
> +
> +/**
> + * struct macsec_secy - MACsec Security Entity
> + * @netdev netdevice for this SecY
> + * @n_rx_sc number of receive secure channels configured on this SecY
> + * @sci secure channel identifier used for tx
> + * @key_len length of keys used by the cipher suite
> + * @icv_len length of ICV used by the cipher suite
> + * @validate_frames validation mode
> + * @operational MAC_Operational flag
> + * @protect_frames enable protection for this SecY
> + * @replay_protect enable packet number checks on receive
> + * @replay_window size of the replay window
> + * @tx_sc transmit secure channel
> + * @rx_sc linked list of receive secure channels
> + */
> +struct macsec_secy {
> +	struct net_device *netdev;
> +	unsigned int n_rx_sc;
> +	sci_t sci;
> +	u16 key_len;
> +	u16 icv_len;
> +	enum validation_type validate_frames;
> +	bool operational;
> +	bool protect_frames;
> +	bool replay_protect;
> +	u32 replay_window;
> +	struct macsec_tx_sc tx_sc;
> +	struct macsec_rx_sc __rcu *rx_sc;
> +};
> +
> +struct pcpu_secy_stats {
> +	struct macsec_dev_stats stats;
> +	struct u64_stats_sync syncp;
> +};
> +
> +/**
> + * struct macsec_dev - private data
> + * @secy SecY config
> + * @real_dev pointer to underlying netdevice
> + * @stats MACsec device stats
> + * @secys linked list of SecY's on the underlying device
> + */
> +struct macsec_dev {
> +	struct macsec_secy secy;
> +	struct net_device *real_dev;
> +	struct pcpu_secy_stats __percpu *stats;
> +	struct list_head secys;
> +};
> +
> +/**
> + * struct macsec_rxh_data - rx_handler private argument
> + * @secys linked list of SecY's on this underlying device
> + */
> +struct macsec_rxh_data {
> +	struct list_head secys;
> +};
> +
> +static struct macsec_dev *macsec_priv(const struct net_device *dev)
> +{
> +	return (struct macsec_dev *)netdev_priv(dev);
> +}
> +
> +static struct macsec_rxh_data *macsec_data_rcu(const struct net_device *dev)
> +{
> +	return rcu_dereference_bh(dev->rx_handler_data);
> +}
> +
> +static struct macsec_rxh_data *macsec_data_rtnl(const struct net_device *dev)
> +{
> +	return rtnl_dereference(dev->rx_handler_data);
> +}
> +
> +struct macsec_cb {
> +	struct aead_request *req;
> +	union {
> +		struct macsec_tx_sa *tx_sa;
> +		struct macsec_rx_sa *rx_sa;
> +	};
> +	u8 assoc_num;
> +	bool valid;
> +	bool has_sci;
> +};
> +
> +static struct macsec_rx_sa *macsec_rxsa_get(struct macsec_rx_sa __rcu *ptr)
> +{
> +	struct macsec_rx_sa *sa = rcu_dereference_bh(ptr);
> +
> +	if (!sa || !sa->active)
> +		return NULL;
> +
> +	if (!atomic_inc_not_zero(&sa->refcnt))
> +		return NULL;
> +
> +	return sa;
> +}
> +
> +static void free_rx_sc_rcu(struct rcu_head *head)
> +{
> +	struct macsec_rx_sc *rx_sc = container_of(head, struct macsec_rx_sc, rcu_head);
> +
> +	free_percpu(rx_sc->stats);
> +	kfree(rx_sc);
> +}
> +
> +static struct macsec_rx_sc *macsec_rxsc_get(struct macsec_rx_sc *sc)
> +{
> +	return atomic_inc_not_zero(&sc->refcnt) ? sc : NULL;
> +}
> +
> +static void macsec_rxsc_put(struct macsec_rx_sc *sc)
> +{
> +	if (atomic_dec_and_test(&sc->refcnt))
> +		call_rcu(&sc->rcu_head, free_rx_sc_rcu);
> +}
> +
> +static void free_rxsa(struct rcu_head *head)
> +{
> +	struct macsec_rx_sa *sa = container_of(head, struct macsec_rx_sa, rcu);
> +
> +	crypto_free_aead(sa->key.tfm);
> +	free_percpu(sa->stats);
> +	macsec_rxsc_put(sa->sc);
> +	kfree(sa);
> +}
> +
> +static void macsec_rxsa_put(struct macsec_rx_sa *sa)
> +{
> +	if (atomic_dec_and_test(&sa->refcnt))
> +		call_rcu(&sa->rcu, free_rxsa);
> +}
> +
> +static struct macsec_tx_sa *macsec_txsa_get(struct macsec_tx_sa __rcu *ptr)
> +{
> +	struct macsec_tx_sa *sa = rcu_dereference_bh(ptr);
> +
> +	if (!sa || !sa->active)
> +		return NULL;
> +
> +	if (!atomic_inc_not_zero(&sa->refcnt))
> +		return NULL;
> +
> +	return sa;
> +}
> +
> +static void free_txsa(struct rcu_head *head)
> +{
> +	struct macsec_tx_sa *sa = container_of(head, struct macsec_tx_sa, rcu);
> +
> +	crypto_free_aead(sa->key.tfm);
> +	free_percpu(sa->stats);
> +	kfree(sa);
> +}
> +
> +static void macsec_txsa_put(struct macsec_tx_sa *sa)
> +{
> +	if (atomic_dec_and_test(&sa->refcnt))
> +		call_rcu(&sa->rcu, free_txsa);
> +}
> +
> +static struct macsec_cb *macsec_skb_cb(struct sk_buff *skb)
> +{
> +	BUILD_BUG_ON(sizeof(struct macsec_cb) > sizeof(skb->cb));
> +	return (struct macsec_cb *)skb->cb;
> +}
> +
> +#define MACSEC_PORT_ES (htons(0x0001))
> +#define MACSEC_PORT_SCB (0x0000)
> +#define MACSEC_UNDEF_SCI ((__force sci_t)0xffffffffffffffffULL)
> +
> +#define DEFAULT_SAK_LEN 16
> +#define DEFAULT_SEND_SCI true
> +#define DEFAULT_ENCRYPT false
> +#define DEFAULT_ENCODING_SA 0
> +
> +static sci_t make_sci(u8 *addr, __be16 port)
> +{
> +	sci_t sci;
> +
> +	memcpy(&sci, addr, ETH_ALEN);
> +	memcpy(((char *)&sci) + ETH_ALEN, &port, sizeof(port));
> +
> +	return sci;
> +}
> +
> +static sci_t macsec_frame_sci(struct macsec_eth_header *hdr, bool sci_present)
> +{
> +	sci_t sci;
> +
> +	if (sci_present)
> +		memcpy(&sci, hdr->secure_channel_id,
> +		       sizeof(hdr->secure_channel_id));
> +	else
> +		sci = make_sci(hdr->eth.h_source, MACSEC_PORT_ES);
> +
> +	return sci;
> +}
> +
> +static unsigned int macsec_sectag_len(bool sci_present)
> +{
> +	return MACSEC_TAG_LEN + (sci_present ? MACSEC_SCI_LEN : 0);
> +}
> +
> +static unsigned int macsec_hdr_len(bool sci_present)
> +{
> +	return macsec_sectag_len(sci_present) + ETH_HLEN;
> +}
> +
> +static unsigned int macsec_extra_len(bool sci_present)
> +{
> +	return macsec_sectag_len(sci_present) + sizeof(__be16);
> +}
> +
> +/* Fill SecTAG according to IEEE 802.1AE-2006 10.5.3 */
> +static void macsec_fill_sectag(struct macsec_eth_header *h,
> +			       const struct macsec_secy *secy, u32 pn)
> +{
> +	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
> +
> +	memset(&h->tci_an, 0, macsec_sectag_len(tx_sc->send_sci));
> +	h->eth.h_proto = htons(ETH_P_MACSEC);
> +
> +	if (tx_sc->send_sci ||
> +	    (secy->n_rx_sc > 1 && !tx_sc->end_station && !tx_sc->scb)) {
> +		h->tci_an |= MACSEC_TCI_SC;
> +		memcpy(&h->secure_channel_id, &secy->sci,
> +		       sizeof(h->secure_channel_id));
> +	} else {
> +		if (tx_sc->end_station)
> +			h->tci_an |= MACSEC_TCI_ES;
> +		if (tx_sc->scb)
> +			h->tci_an |= MACSEC_TCI_SCB;
> +	}
> +
> +	h->packet_number = htonl(pn);
> +
> +	/* with GCM, C/E clear for !encrypt, both set for encrypt */
> +	if (tx_sc->encrypt)
> +		h->tci_an |= MACSEC_TCI_CONFID;
> +	else if (secy->icv_len != DEFAULT_ICV_LEN)
> +		h->tci_an |= MACSEC_TCI_C;
> +
> +	h->tci_an |= tx_sc->encoding_sa;
> +}
> +
> +static void macsec_set_shortlen(struct macsec_eth_header *h, size_t data_len)
> +{
> +	if (data_len < MACSEC_SHORTLEN_THR)
> +		h->short_length = data_len;
> +}
> +
> +/* minimum secure data length deemed "not short", see IEEE 802.1AE-2006 9.7 */
> +#define MIN_NON_SHORT_LEN 48
> +
> +/* validate MACsec packet according to IEEE 802.1AE-2006 9.12 */
> +static bool macsec_validate_skb(struct sk_buff *skb, u16 icv_len)
> +{
> +	struct macsec_eth_header *h = (struct macsec_eth_header *)skb->data;
> +	int len = skb->len - 2 * ETH_ALEN;
> +	int extra_len = macsec_extra_len(!!(h->tci_an & MACSEC_TCI_SC)) + icv_len;
> +
> +	/* a) It comprises at least 17 octets */
> +	if (skb->len <= 16)
> +		return false;
> +
> +	/* b) MACsec EtherType: already checked */
> +
> +	/* c) V bit is clear */
> +	if (h->tci_an & MACSEC_TCI_VERSION)
> +		return false;
> +
> +	/* d) ES or SCB => !SC */
> +	if ((h->tci_an & MACSEC_TCI_ES || h->tci_an & MACSEC_TCI_SCB) &&
> +	    (h->tci_an & MACSEC_TCI_SC))
> +		return false;
> +
> +	/* e) Bits 7 and 8 of octet 4 of the SecTAG are clear */
> +	if (h->unused)
> +		return false;
> +
> +	/* rx.pn != 0 (figure 10-5) */
> +	if (!h->packet_number)
> +		return false;
> +
> +	/* length check, f) g) h) i) */
> +	if (h->short_length)
> +		return len == extra_len + h->short_length;
> +	return len >= extra_len + MIN_NON_SHORT_LEN;
> +}
> +
> +#define MACSEC_NEEDED_HEADROOM (macsec_extra_len(true))
> +#define MACSEC_NEEDED_TAILROOM MACSEC_MAX_ICV_LEN
> +
> +static void macsec_fill_iv(unsigned char *iv, sci_t sci, u32 pn)
> +{
> +	struct gcm_iv *gcm_iv = (struct gcm_iv *)iv;
> +
> +	gcm_iv->sci = sci;
> +	gcm_iv->pn = htonl(pn);
> +}
> +
> +static struct macsec_eth_header *macsec_ethhdr(struct sk_buff *skb)
> +{
> +	return (struct macsec_eth_header *)skb_mac_header(skb);
> +}
> +
> +static u32 tx_sa_update_pn(struct macsec_tx_sa *tx_sa, struct macsec_secy *secy)
> +{
> +	u32 pn;
> +
> +	spin_lock_bh(&tx_sa->lock);
> +	pn = tx_sa->next_pn;
> +
> +	tx_sa->next_pn++;
> +	if (tx_sa->next_pn == 0) {
> +		pr_debug("PN wrapped, transitionning to !oper\n");
> +		tx_sa->active = false;
> +		if (secy->protect_frames)
> +			secy->operational = false;
> +	}
> +	spin_unlock_bh(&tx_sa->lock);
> +
> +	return pn;
> +}
> +
> +static void macsec_encrypt_finish(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct macsec_dev *macsec = netdev_priv(dev);
> +
> +	skb->dev = macsec->real_dev;
> +	skb_reset_mac_header(skb);
> +	skb->protocol = eth_hdr(skb)->h_proto;
> +}
> +
> +static void macsec_count_tx(struct sk_buff *skb, struct macsec_tx_sc *tx_sc,
> +			    struct macsec_tx_sa *tx_sa)
> +{
> +	struct pcpu_tx_sc_stats *txsc_stats = this_cpu_ptr(tx_sc->stats);
> +
> +	u64_stats_update_begin(&txsc_stats->syncp);
> +	if (tx_sc->encrypt) {
> +		txsc_stats->stats.OutOctetsEncrypted += skb->len;
> +		txsc_stats->stats.OutPktsEncrypted++;
> +		this_cpu_inc(tx_sa->stats->OutPktsEncrypted);
> +	} else {
> +		txsc_stats->stats.OutOctetsProtected += skb->len;
> +		txsc_stats->stats.OutPktsProtected++;
> +		this_cpu_inc(tx_sa->stats->OutPktsProtected);
> +	}
> +	u64_stats_update_end(&txsc_stats->syncp);
> +}
> +
> +static void count_tx(struct net_device *dev, int ret, int len)
> +{
> +	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
> +		struct pcpu_sw_netstats *stats = this_cpu_ptr(dev->tstats);
> +
> +		u64_stats_update_begin(&stats->syncp);
> +		stats->tx_packets++;
> +		stats->tx_bytes += len;
> +		u64_stats_update_end(&stats->syncp);
> +	} else {
> +		dev->stats.tx_dropped++;
> +	}
> +}
> +
> +static void macsec_encrypt_done(struct crypto_async_request *base, int err)
> +{
> +	struct sk_buff *skb = base->data;
> +	struct net_device *dev = skb->dev;
> +	struct macsec_dev *macsec = macsec_priv(dev);
> +	struct macsec_tx_sa *sa = macsec_skb_cb(skb)->tx_sa;
> +	int len, ret;
> +
> +	aead_request_free(macsec_skb_cb(skb)->req);
> +
> +	rcu_read_lock_bh();
> +	macsec_encrypt_finish(skb, dev);
> +	macsec_count_tx(skb, &macsec->secy.tx_sc, macsec_skb_cb(skb)->tx_sa);
> +	len = skb->len;
> +	ret = dev_queue_xmit(skb);
> +	count_tx(dev, ret, len);
> +	rcu_read_unlock_bh();
> +
> +	macsec_txsa_put(sa);
> +	dev_put(dev);
> +}
> +
> +static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
> +				      struct net_device *dev)
> +{
> +	int ret;
> +	struct scatterlist sg[MAX_SKB_FRAGS + 1];
> +	unsigned char iv[GCM_AES_IV_LEN];
> +	struct ethhdr *eth;
> +	struct macsec_eth_header *hh;
> +	size_t unprotected_len;
> +	struct aead_request *req;
> +	struct macsec_secy *secy;
> +	struct macsec_tx_sc *tx_sc;
> +	struct macsec_tx_sa *tx_sa;
> +	struct macsec_dev *macsec = macsec_priv(dev);
> +	u32 pn;
> +
> +	secy = &macsec->secy;
> +	tx_sc = &secy->tx_sc;
> +
> +	/* 10.5.1 TX SA assignment */
> +	tx_sa = macsec_txsa_get(tx_sc->sa[tx_sc->encoding_sa]);
> +	if (!tx_sa) {
> +		secy->operational = false;
> +		kfree_skb(skb);
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	if (unlikely(skb_headroom(skb) < MACSEC_NEEDED_HEADROOM ||
> +		     skb_tailroom(skb) < MACSEC_NEEDED_TAILROOM)) {
> +		struct sk_buff *nskb = skb_copy_expand(skb,
> +						       MACSEC_NEEDED_HEADROOM,
> +						       MACSEC_NEEDED_TAILROOM,
> +						       GFP_ATOMIC);
> +		if (likely(nskb)) {
> +			consume_skb(skb);
> +			skb = nskb;
> +		} else {
> +			macsec_txsa_put(tx_sa);
> +			kfree_skb(skb);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +	} else {
> +		skb = skb_unshare(skb, GFP_ATOMIC);
> +		if (!skb) {
> +			macsec_txsa_put(tx_sa);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +	}
> +
> +	unprotected_len = skb->len;
> +	eth = eth_hdr(skb);
> +	hh = (struct macsec_eth_header *)skb_push(skb, macsec_extra_len(tx_sc->send_sci));
> +	memmove(hh, eth, 2 * ETH_ALEN);
> +
> +	pn = tx_sa_update_pn(tx_sa, secy);
> +	if (pn == 0) {
> +		macsec_txsa_put(tx_sa);
> +		kfree_skb(skb);
> +		return ERR_PTR(-ENOLINK);
> +	}
> +	macsec_fill_sectag(hh, secy, pn);
> +	macsec_set_shortlen(hh, unprotected_len - 2 * ETH_ALEN);
> +
> +	macsec_fill_iv(iv, secy->sci, pn);
> +
> +	skb_put(skb, secy->icv_len);
> +
> +	if (skb->len - ETH_HLEN > macsec_priv(dev)->real_dev->mtu) {
> +		struct pcpu_secy_stats *secy_stats = this_cpu_ptr(macsec->stats);
> +
> +		u64_stats_update_begin(&secy_stats->syncp);
> +		secy_stats->stats.OutPktsTooLong++;
> +		u64_stats_update_end(&secy_stats->syncp);
> +
> +		macsec_txsa_put(tx_sa);
> +		kfree_skb(skb);
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	req = aead_request_alloc(tx_sa->key.tfm, GFP_ATOMIC);
> +	if (!req) {
> +		macsec_txsa_put(tx_sa);
> +		kfree_skb(skb);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	sg_init_table(sg, MAX_SKB_FRAGS + 1);
> +	skb_to_sgvec(skb, sg, 0, skb->len);
> +
> +	if (tx_sc->encrypt) {
> +		int len = skb->len - macsec_hdr_len(tx_sc->send_sci) -
> +			  secy->icv_len;
> +		aead_request_set_crypt(req, sg, sg, len, iv);
> +		aead_request_set_ad(req, macsec_hdr_len(tx_sc->send_sci));
> +	} else {
> +		aead_request_set_crypt(req, sg, sg, 0, iv);
> +		aead_request_set_ad(req, skb->len - secy->icv_len);
> +	}
> +
> +	macsec_skb_cb(skb)->req = req;
> +	macsec_skb_cb(skb)->tx_sa = tx_sa;
> +	aead_request_set_callback(req, 0, macsec_encrypt_done, skb);
> +
> +	dev_hold(skb->dev);
> +	ret = crypto_aead_encrypt(req);
> +	if (ret == -EINPROGRESS) {
> +		return ERR_PTR(ret);
> +	} else if (ret != 0) {
> +		dev_put(skb->dev);
> +		kfree_skb(skb);
> +		aead_request_free(req);
> +		macsec_txsa_put(tx_sa);
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	dev_put(skb->dev);
> +	aead_request_free(req);
> +	macsec_txsa_put(tx_sa);
> +
> +	return skb;
> +}
> +
> +static bool macsec_post_decrypt(struct sk_buff *skb, struct macsec_secy *secy, u32 pn)
> +{
> +	struct macsec_rx_sa *rx_sa = macsec_skb_cb(skb)->rx_sa;
> +	struct pcpu_rx_sc_stats *rxsc_stats = this_cpu_ptr(rx_sa->sc->stats);
> +	struct macsec_eth_header *hdr = macsec_ethhdr(skb);
> +	u32 lowest_pn = 0;
> +
> +	spin_lock(&rx_sa->lock);
> +	if (rx_sa->next_pn >= secy->replay_window)
> +		lowest_pn = rx_sa->next_pn - secy->replay_window;
> +
> +	/* Now perform replay protection check again
> +	 * (see IEEE 802.1AE-2006 figure 10-5)
> +	 */
> +	if (secy->replay_protect && pn < lowest_pn) {
> +		spin_unlock(&rx_sa->lock);
> +		u64_stats_update_begin(&rxsc_stats->syncp);
> +		rxsc_stats->stats.InPktsLate++;
> +		u64_stats_update_end(&rxsc_stats->syncp);
> +		return false;
> +	}
> +
> +	if (secy->validate_frames != MACSEC_VALIDATE_DISABLED) {
> +		u64_stats_update_begin(&rxsc_stats->syncp);
> +		if (hdr->tci_an & MACSEC_TCI_E)
> +			rxsc_stats->stats.InOctetsDecrypted += skb->len;
> +		else
> +			rxsc_stats->stats.InOctetsValidated += skb->len;
> +		u64_stats_update_end(&rxsc_stats->syncp);
> +	}
> +
> +	if (!macsec_skb_cb(skb)->valid) {
> +		spin_unlock(&rx_sa->lock);
> +
> +		/* 10.6.5 */
> +		if (hdr->tci_an & MACSEC_TCI_C ||
> +		    secy->validate_frames == MACSEC_VALIDATE_STRICT) {
> +			u64_stats_update_begin(&rxsc_stats->syncp);
> +			rxsc_stats->stats.InPktsNotValid++;
> +			u64_stats_update_end(&rxsc_stats->syncp);
> +			return false;
> +		}
> +
> +		u64_stats_update_begin(&rxsc_stats->syncp);
> +		if (secy->validate_frames == MACSEC_VALIDATE_CHECK) {
> +			rxsc_stats->stats.InPktsInvalid++;
> +			this_cpu_inc(rx_sa->stats->InPktsInvalid);
> +		} else if (pn < lowest_pn) {
> +			rxsc_stats->stats.InPktsDelayed++;
> +		} else {
> +			rxsc_stats->stats.InPktsUnchecked++;
> +		}
> +		u64_stats_update_end(&rxsc_stats->syncp);
> +	} else {
> +		u64_stats_update_begin(&rxsc_stats->syncp);
> +		if (pn < lowest_pn) {
> +			rxsc_stats->stats.InPktsDelayed++;
> +		} else {
> +			rxsc_stats->stats.InPktsOK++;
> +			this_cpu_inc(rx_sa->stats->InPktsOK);
> +		}
> +		u64_stats_update_end(&rxsc_stats->syncp);
> +
> +		if (pn >= rx_sa->next_pn)
> +			rx_sa->next_pn = pn + 1;
> +		spin_unlock(&rx_sa->lock);
> +	}
> +
> +	return true;
> +}
> +
> +static void macsec_reset_skb(struct sk_buff *skb, struct net_device *dev)
> +{
> +	skb->pkt_type = PACKET_HOST;
> +	skb->protocol = eth_type_trans(skb, dev);
> +
> +	skb_reset_network_header(skb);
> +	if (!skb_transport_header_was_set(skb))
> +		skb_reset_transport_header(skb);
> +	skb_reset_mac_len(skb);
> +}
> +
> +static void macsec_finalize_skb(struct sk_buff *skb, u8 icv_len, u8 hdr_len)
> +{
> +	memmove(skb->data + hdr_len, skb->data, 2 * ETH_ALEN);
> +	skb_pull(skb, hdr_len);
> +	pskb_trim_unique(skb, skb->len - icv_len);
> +}
> +
> +static void count_rx(struct net_device *dev, int len)
> +{
> +	struct pcpu_sw_netstats *stats = this_cpu_ptr(dev->tstats);
> +
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->rx_packets++;
> +	stats->rx_bytes += len;
> +	u64_stats_update_end(&stats->syncp);
> +}
> +
> +static void macsec_decrypt_done(struct crypto_async_request *base, int err)
> +{
> +	struct sk_buff *skb = base->data;
> +	struct net_device *dev = skb->dev;
> +	struct macsec_dev *macsec = macsec_priv(dev);
> +	struct macsec_rx_sa *rx_sa = macsec_skb_cb(skb)->rx_sa;
> +	int len, ret;
> +	u32 pn;
> +
> +	aead_request_free(macsec_skb_cb(skb)->req);
> +
> +	rcu_read_lock_bh();
> +	pn = ntohl(macsec_ethhdr(skb)->packet_number);
> +	if (!macsec_post_decrypt(skb, &macsec->secy, pn)) {
> +		rcu_read_unlock_bh();
> +		kfree_skb(skb);
> +		goto out;
> +	}
> +
> +	macsec_finalize_skb(skb, macsec->secy.icv_len,
> +			    macsec_extra_len(macsec_skb_cb(skb)->has_sci));
> +	macsec_reset_skb(skb, macsec->secy.netdev);
> +
> +	len = skb->len;
> +	ret = netif_rx(skb);
> +	if (ret == NET_RX_SUCCESS)
> +		count_rx(dev, len);
> +	else
> +		macsec->secy.netdev->stats.rx_dropped++;
> +
> +	rcu_read_unlock_bh();
> +
> +out:
> +	macsec_rxsa_put(rx_sa);
> +	dev_put(dev);
> +	return;
> +}
> +
> +static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
> +				      struct net_device *dev,
> +				      struct macsec_rx_sa *rx_sa,
> +				      sci_t sci,
> +				      struct macsec_secy *secy)
> +{
> +	int ret;
> +	struct scatterlist sg[MAX_SKB_FRAGS + 1];
> +	unsigned char iv[GCM_AES_IV_LEN];
> +	struct aead_request *req;
> +	struct macsec_eth_header *hdr;
> +	u16 icv_len = secy->icv_len;
> +
> +	macsec_skb_cb(skb)->valid = 0;

Please use true/false for boolean variables.

> +		macsec_skb_cb(skb)->valid = 1;

Likewise.

> +static void handle_not_macsec(struct sk_buff *skb)
> +{
> +	struct macsec_rxh_data *rxd;
> +	struct macsec_dev *macsec;
> +
> +	rcu_read_lock_bh();

"bh" should be implicit in this receive code path, so plain rcu_read_lock() should
be sufficient.

> +static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
> +{
 ...
> +	rcu_read_lock_bh();

Likewise.

Otherwise looks really good to me.
