From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Tue, 01 Mar 2016 15:02:51 +0100
Message-ID: <1456840971.3926.29.camel@sipsolutions.net>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	 (sfid-20160226_140925_426277_05F8C3B0)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	dave.taht@gmail.com, emmanuel.grumbach@intel.com, nbd@openwrt.org,
	Tim Shepard <shep@alum.mit.edu>
To: Michal Kazior <michal.kazior@tieto.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35312 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbcCAOCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 09:02:55 -0500
In-Reply-To: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com> (sfid-20160226_140925_426277_05F8C3B0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-02-26 at 14:09 +0100, Michal Kazior wrote:
>=20
> +typedef u64 codel_time_t;

Do we really need this? And if yes, does it have to be in the public
header file? Why a typedef anyway?

> - * @txq_ac_max_pending: maximum number of frames per AC pending in
> all txq
> - *	entries for a vif.
> + * @txq_cparams: codel parameters to control tx queueing dropping
> behavior
> + * @txq_limit: maximum number of frames queuesd

typo - queued

> @@ -2133,7 +2155,8 @@ struct ieee80211_hw {
> =C2=A0	u8 uapsd_max_sp_len;
> =C2=A0	u8 n_cipher_schemes;
> =C2=A0	const struct ieee80211_cipher_scheme *cipher_schemes;
> -	int txq_ac_max_pending;
> +	struct codel_params txq_cparams;

Should this really be a parameter the driver determines?

> +static void ieee80211_if_setup_no_queue(struct net_device *dev)
> +{
> +	ieee80211_if_setup(dev);
> +	dev->priv_flags |=3D IFF_NO_QUEUE;
> +	/* Note for backporters: use dev->tx_queue_len =3D 0 instead
> of IFF_ */

Heh. Remove that comment; we have an spatch in backports already :)

> --- a/net/mac80211/sta_info.h
> +++ b/net/mac80211/sta_info.h
> @@ -19,6 +19,7 @@
> =C2=A0#include <linux/etherdevice.h>
> =C2=A0#include <linux/rhashtable.h>
> =C2=A0#include "key.h"
> +#include "codel_i.h"
> =C2=A0
> =C2=A0/**
> =C2=A0 * enum ieee80211_sta_info_flags - Stations flags
> @@ -327,6 +328,32 @@ struct mesh_sta {
> =C2=A0
> =C2=A0DECLARE_EWMA(signal, 1024, 8)
> =C2=A0
> +struct txq_info;
> +
> +/**
> + * struct txq_flow - per traffic flow queue
> + *
> + * This structure is used to distinguish and queue different traffic
> flows
> + * separately for fair queueing/AQM purposes.
> + *
> + * @txqi: txq_info structure it is associated at given time
> + * @flowchain: can be linked to other flows for RR purposes
> + * @backlogchain: can be linked to other flows for backlog sorting
> purposes
> + * @queue: sk_buff queue
> + * @cvars: codel state vars
> + * @backlog: number of bytes pending in the queue
> + * @deficit: used for fair queueing balancing
> + */
> +struct txq_flow {
> +	struct txq_info *txqi;
> +	struct list_head flowchain;
> +	struct list_head backlogchain;
> +	struct sk_buff_head queue;
> +	struct codel_vars cvars;
> +	u32 backlog;
> +	u32 deficit;
> +};
> +
> =C2=A0/**
> =C2=A0 * struct sta_info - STA information
> =C2=A0 *
> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index af584f7cdd63..f42f898cb8b5 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -34,6 +34,7 @@
> =C2=A0#include "wpa.h"
> =C2=A0#include "wme.h"
> =C2=A0#include "rate.h"
> +#include "codel.h"

> +static inline codel_time_t
> +custom_codel_get_enqueue_time(struct sk_buff *skb)

There are a lot of inlines here - first of all, do they all need to be
inline?

And secondly, perhaps it would make some sense to move this into
another file?

johannes
