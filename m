From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 5/6] v4 Add RX packet classification interface
Date: Wed, 27 Apr 2011 19:12:14 +0100
Message-ID: <1303927934.2875.82.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204040.23054.87188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20300 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab1D0SMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:12:18 -0400
In-Reply-To: <20110421204040.23054.87188.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
[...]
> diff --git a/ethtool.c b/ethtool.c
> index 15af86a..421fe20 100644
> --- a/ethtool.c
> +++ b/ethtool.c
[...]
> @@ -926,16 +862,45 @@ static void parse_cmdline(int argc, char **argp)
>  				i = argc;
>  				break;
>  			}
> -			if (mode == MODE_SNTUPLE) {
> +			if (mode == MODE_SCLSRULE) {
>  				if (!strcmp(argp[i], "flow-type")) {
>  					i += 1;
>  					if (i >= argc) {
>  						exit_bad_args();
>  						break;
>  					}
> -					parse_rxntupleopts(argc, argp, i);
> -					i = argc;
> -					break;
> +					if (rxclass_parse_ruleopts(&argp[i],
> +							argc - i,
> +							&rx_rule_fs) < 0) {
> +						exit_bad_args();
> +					} else {
> +						i = argc;
> +						rx_class_rule_added = 1;
> +					}
> +				} else if (!strcmp(argp[i], "class-rule-del")) {

A shorter keyword like 'delete' would do, since the -U option is only
used for flow classification.

> +					i += 1;
> +					if (i >= argc) {
> +						exit_bad_args();
> +						break;
> +					}
> +					rx_class_rule_del =
> +						get_uint_range(argp[i], 0,
> +							       INT_MAX);
> +				} else {
> +					exit_bad_args();
> +				}
> +				break;
> +			}
> +			if (mode == MODE_GCLSRULE) {
> +				if (!strcmp(argp[i], "class-rule")) {

This keyword seems redundant.

[...]
> @@ -3163,21 +3068,130 @@ static int do_permaddr(int fd, struct ifreq *ifr)
>  	return err;
>  }
>  
> +static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
> +			       struct ethtool_rx_ntuple_flow_spec *ntuple)
> +{
> +	int i;

Should be size_t, since it's compared with a sizeof() expression.

> +	/* verify location is not specified */
> +	if (fsp->location != RX_CLS_LOC_UNSPEC)
> +		return -1;
> +
> +	/* verify ring cookie can transfer to action */
> +	if (fsp->ring_cookie > INT_MAX &&
> +	    ~fsp->ring_cookie > 1)
> +		return -1;

The second part of this condition would be more clearly expressed as:

	fsp->ring_cookie < (u64)(-2)

> +	/* verify only one field is setting data field */
> +	if ((fsp->flow_type & FLOW_EXT) &&
> +	    (fsp->m_ext.data[0] || fsp->m_ext.data[1]) &&
> +	    fsp->m_ext.vlan_etype)
> +		return -1;
> +
> +	/* initialize entire ntuple to all 0xFF */
> +	memset(ntuple, ~0, sizeof(*ntuple));

The comment needs to explain *why* the value is ~0 rather than 0.  I
assume the idea is to set the masks to ~0 if they are not initialised
below.

> +	/* set non-filter values */
> +	ntuple->flow_type = fsp->flow_type;
> +	ntuple->action = fsp->ring_cookie;
> +
> +	/* copy header portion over */
> +	memcpy(&ntuple->h_u, &fsp->h_u, sizeof(fsp->h_u));

This deserves a comment that the two h_u fields are different unions,
but are defined identically except for padding at the end.

> +	/* copy mask portion over and invert */
> +	memcpy(&ntuple->m_u, &fsp->m_u, sizeof(fsp->m_u));
> +	for (i = 0; i < sizeof(fsp->m_u); i++)
> +		ntuple->m_u.hdata[i] ^= 0xFF;
> +
> +	/* copy extended fields */
> +	if (fsp->flow_type & FLOW_EXT) {
> +		ntuple->vlan_tag =
> +			ntohs(fsp->h_ext.vlan_tci);
> +		ntuple->vlan_tag_mask =
> +			~ntohs(fsp->m_ext.vlan_tci);
> +		if (fsp->m_ext.vlan_etype) {
> +			ntuple->data =
> +				ntohl(fsp->h_ext.vlan_etype);
> +			ntuple->data_mask =
> +				~(u64)ntohl(fsp->m_ext.vlan_etype);
> +		} else {
> +			ntuple->data =
> +				(u64)ntohl(fsp->h_ext.data[0]);
> +			ntuple->data |=
> +				(u64)ntohl(fsp->h_ext.data[1]) << 32;
> +			ntuple->data_mask =
> +				(u64)ntohl(~fsp->m_ext.data[0]);
> +			ntuple->data_mask |=
> +				(u64)ntohl(~fsp->m_ext.data[1]) << 32;
> +		}
> +	}

I think it would be clearer to add:

	else {
		ntuple->vlan_tag_mask = ~(u16)0;
		ntuple->data_mask = ~(u64)0;
	}

rather than use memset() above.

> +	return 0;
> +}
> +
>  static int do_srxntuple(int fd, struct ifreq *ifr)
>  {
> +	struct ethtool_rx_ntuple ntuplecmd;
> +	struct ethtool_value eval;
>  	int err;
>  
> -	if (sntuple_changed) {
> -		struct ethtool_rx_ntuple ntuplecmd;
> +	/* verify if Ntuple is supported on the HW */

This comment is inaccurate.

> +	err = flow_spec_to_ntuple(&rx_rule_fs, &ntuplecmd.fs);
> +	if (err)
> +		return -1;
> +
> +	/*
> +	 * Check to see if the flag is set for N-tuple, this allows
> +	 * us to avoid the possible EINVAL response for the N-tuple
> +	 * flag not being set on the device
> +	 */
> +	eval.cmd = ETHTOOL_GFLAGS;
> +	ifr->ifr_data = (caddr_t)&eval;
> +	err = ioctl(fd, SIOCETHTOOL, ifr);
> +	if (err || !(eval.data & ETH_FLAG_NTUPLE))
> +		return -1;
>  
> -		ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
> -		memcpy(&ntuplecmd.fs, &ntuple_fs,
> -		       sizeof(struct ethtool_rx_ntuple_flow_spec));
> +	/* send rule via N-tuple */
> +	ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
> +	ifr->ifr_data = (caddr_t)&ntuplecmd;
> +	err = ioctl(fd, SIOCETHTOOL, ifr);
>  
> -		ifr->ifr_data = (caddr_t)&ntuplecmd;
> -		err = ioctl(fd, SIOCETHTOOL, ifr);
> -		if (err < 0)
> -			perror("Cannot add new RX n-tuple filter");
> +	/*
> +	 * Display error only if reponse is something other than op not
> +	 * supported.  It is possible that the interface uses the network
> +	 * flow classifier interface instead of N-tuple. 
> +	 */ 
> +	if (err && errno != EOPNOTSUPP)
> +		perror("Cannot add new rule via N-tuple");
> +
> +	return err;
> +}
> +
> +static int do_srxclsrule(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +
> +	if (rx_class_rule_added) {
> +		/* attempt to add rule via N-tuple specifier */
> +		err = do_srxntuple(fd, ifr);
> +		if (!err)
> +			return 0;
> +
> +		/* attempt to add rule via network flow classifier */
> +		err = rxclass_rule_ins(fd, ifr, &rx_rule_fs);
> +		if (err < 0) {
> +			fprintf(stderr, "Cannot insert"
> +				" classification rule\n");
> +			return 1;
> +		}

Is this the right order to try them?  I'm not sure.

> +	} else if (rx_class_rule_del >= 0) {
> +		err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
> +
> +		if (err < 0) {
> +			fprintf(stderr, "Cannot delete"
> +				" classification rule\n");
> +			return 1;
> +		}
>  	} else {
>  		exit_bad_args();
>  	}
[...]
> diff --git a/rxclass.c b/rxclass.c
> new file mode 100644
> index 0000000..5ad0639
> --- /dev/null
> +++ b/rxclass.c
> @@ -0,0 +1,1106 @@
> +/*
> + * Copyright (C) 2008 Sun Microsystems, Inc. All rights reserved.
> + */
> +#include <stdio.h>
> +#include <stdint.h>
> +#include <stddef.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <errno.h>
> +
> +#include <linux/sockios.h>
> +#include <arpa/inet.h>
> +#include "ethtool-util.h"
> +#include "ethtool-bitops.h"
> +
> +/*
> + * This is a rule manager implementation for ordering rx flow
> + * classification rules in a longest prefix first match order.
> + * The assumption is that this rule manager is the only one adding rules to
> + * the device's hardware classifier.
> + */
> +
> +struct rmgr_ctrl {
> +	/* slot contains a bitmap indicating which filters are valid */
> +	unsigned long		*slot;
> +	__u32			n_rules;
> +	__u32			size;
> +};
> +
> +static struct rmgr_ctrl rmgr;
> +static int rmgr_init_done = 0;
> +
> +static void invert_flow_mask(struct ethtool_rx_flow_spec *fsp)
> +{
> +	int i;

Should be size_t, since it's compared with a sizeof() expression.

> +	for (i = 0; i < sizeof(fsp->m_u); i++)
> +		fsp->m_u.hdata[i] ^= 0xFF;
> +}
> +
> +static void rmgr_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
> +{
> +	u64 data, datam;
> +	__u16 etype, etypem, tci, tcim;
> +
> +	if (!(fsp->flow_type & FLOW_EXT))
> +		return;
> +
> +	etype = ntohs(fsp->h_ext.vlan_etype);
> +	etypem = ntohs(~fsp->m_ext.vlan_etype);
> +	tci = ntohs(fsp->h_ext.vlan_tci);
> +	tcim = ntohs(~fsp->m_ext.vlan_tci);
> +	data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
> +	data = (u64)ntohl(fsp->h_ext.data[1]);
> +	datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
> +	datam |= (u64)ntohl(~fsp->m_ext.data[1]);
> +
> +	fprintf(stdout,
> +		"\tVLAN EtherType: 0x%x mask: 0x%x\n"

Lower-case 'ethertype', please.

> +		"\tVLAN: 0x%x mask: 0x%x\n"
> +		"\tUser-defined: 0x%Lx mask: 0x%Lx\n",

'L' is not documented as an integer modifier for printf().  Use 'll'
instead.

> +		etype, etypem, tci, tcim, data, datam);
> +}
> +
> +static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
> +{
> +	unsigned char	*smac, *smacm, *dmac, *dmacm;
> +	__u32		sip, dip, sipm, dipm, flow_type;
> +	__u16		proto, protom;
> +
> +	if (fsp->location != RX_CLS_LOC_UNSPEC)
> +		fprintf(stdout,	"Filter: %d\n", fsp->location);
> +	else
> +		fprintf(stdout,	"Filter: Unspecified\n");
> +
> +	flow_type = fsp->flow_type & ~FLOW_EXT;
> +
> +	invert_flow_mask(fsp);
> +
> +	switch (flow_type) {
> +	case TCP_V4_FLOW:
> +	case UDP_V4_FLOW:
> +	case SCTP_V4_FLOW:
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +	case IP_USER_FLOW:
> +		sip = ntohl(fsp->h_u.tcp_ip4_spec.ip4src);
> +		dip = ntohl(fsp->h_u.tcp_ip4_spec.ip4dst);
> +		sipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4src);
> +		dipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4dst);

I think this will work for AH_V4, ESP_V4 and IP_USER due to similar
structure layout, but it's kind of dodgy.  Please handle each structure
type separately.

[...]
> +static int rmgr_del(__u32 loc)
> +{
> +	/* verify rule exists before attempting to delete */
> +	int err = rmgr_find(loc);
> +	if (err)
> +		return err;
> +
> +	/* clear bit for the rule */
> +	clear_bit(loc, rmgr.slot);
> +
> +	return 0;
> +}
> +
> +static int rmgr_add(struct ethtool_rx_flow_spec *fsp)
> +{
> +	__u32 loc = fsp->location;
> +
> +	/* location provided, insert rule and update regions to match rule */
> +	if (loc != RX_CLS_LOC_UNSPEC)
> +		return rmgr_ins(loc);
> +
> +	/* start at the end of the list since it is lowest priority */
> +	loc = rmgr.size - 1;
> +
> +	/* only part of last word is set so fill in remaining bits and test */
> +	if (!~(rmgr.slot[loc / BITS_PER_LONG] |
> +	       (~1UL << (loc % BITS_PER_LONG))))
> +		loc -= 1 + (loc % BITS_PER_LONG);

I think this is meant to avoid the need to search for bits in a partial
word but it's a very non-obvious way to do that.

> +	/* find an open slot */
> +	while (loc != RX_CLS_LOC_UNSPEC && !~rmgr.slot[loc / BITS_PER_LONG])
> +		loc -= BITS_PER_LONG;

Just because RX_CLS_LOC_UNSPEC happens to be equal to -1 doesn't mean
it's a good idea to use the name here!

> +	/* find and use available location in slot */
> +	while (loc != RX_CLS_LOC_UNSPEC && test_bit(loc, rmgr.slot))
> +		loc--;
> +
> +       /* location found, insert rule */
> +       if (loc != RX_CLS_LOC_UNSPEC) {
> +               fsp->location = loc;
> +               return rmgr_ins(loc);
> +       }

I think it would be clearer to use a separate word index:

	__u32 loc;
	int i;

	/* location provided, insert rule and update regions to match rule */
	if (fs->location != RX_CLS_LOC_UNSPEC)
		return rmgr_ins(fs->location);

	/* start at the end of the list since it is lowest priority */
	for (i = rmgr.size / BITS_PER_LONG - 1; i >= 0; i--) {
		if (~rmgr.slot[i]) {
			loc = i * BITS_PER_LONG - 1;
			while (test_bit(loc, rmgr.slot))
				loc--;

			/* location found, insert rule */
			fsp->location = loc;
			return rmgr_ins(loc);
		}
	}

[...]
> +int rxclass_rule_getall(int fd, struct ifreq *ifr)
> +{
> +	struct ethtool_rxnfc nfccmd;
> +	int err, i, j;
> +
> +	/* init table of available rules */
> +	err = rmgr_init(fd, ifr);
> +	if (err < 0)
> +		return err;
> +
> +	fprintf(stdout, "Total %d rules\n\n", rmgr.n_rules);
> +
> +	/* fetch and display all available rules */
> +	for (i = 0; i < rmgr.size; i += BITS_PER_LONG) {
> +		if (!~rmgr.slot[i / BITS_PER_LONG])
> +			continue;

The '~' is wrong.  We want to skip words where all bits are clear, not
where all bits are set.

[...]
> +int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc)
> +{
> +	struct ethtool_rxnfc nfccmd;
> +	int err;
> +
> +	/* init table of available rules */
> +	err = rmgr_init(fd, ifr);
> +	if (err < 0)
> +		return err;
> +
> +	/* verify rule exists before attempting to display */
> +	err = rmgr_find(loc);
> +	if (err < 0)
> +		return err;

Is this really necessary?  Shouldn't we let the driver check that for
us, and save the cost of initialising the rule manager?

[...]
> +int rxclass_rule_ins(int fd, struct ifreq *ifr,
> +		     struct ethtool_rx_flow_spec *fsp)
> +{
> +	struct ethtool_rxnfc nfccmd;
> +	int err;
> +
> +	/* init table of available rules */
> +	err = rmgr_init(fd, ifr);
> +	if (err < 0)
> +		return err;
> +
> +	/* verify rule location */
> +	err = rmgr_add(fsp);
> +	if (err < 0)
> +		return err;
> +
> +	/* notify netdev of new rule */
> +	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
> +	nfccmd.fs = *fsp;
> +	ifr->ifr_data = (caddr_t)&nfccmd;
> +	err = ioctl(fd, SIOCETHTOOL, ifr);
> +	if (err < 0) {
> +		perror("rmgr: Cannot insert RX class rule");
> +		return -1;
> +	}
> +	rmgr.n_rules++;

If we're about to destroy the rule manager immediately afterwards, why
bother maintaining n_rules?

> +	printf("Added rule with ID %d\n", fsp->location);
> +
> +	rmgr_cleanup();
> +
> +	return 0;
> +}
> +
> +int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc)
> +{
> +	struct ethtool_rxnfc nfccmd;
> +	int err;
> +
> +	/* init table of available rules */
> +	err = rmgr_init(fd, ifr);
> +	if (err < 0)
> +		return err;
> +
> +	/* verify rule exists */
> +	err = rmgr_del(loc);
> +	if (err < 0)
> +		return err;

Again, I think that can be left to the driver.

[...]
> +typedef enum {
> +	OPT_NONE = 0,
> +	OPT_S32,
> +	OPT_U8,
> +	OPT_U16,
> +	OPT_U32,
> +	OPT_U64,
> +	OPT_BE16,
> +	OPT_BE32,
> +	OPT_BE64,
> +	OPT_IP4,
> +	OPT_MAC,
> +} rule_opt_type_t;
> +
> +#define NFC_FLAG_RING		0x001
> +#define NFC_FLAG_LOC		0x002
> +#define NFC_FLAG_SADDR		0x004
> +#define NFC_FLAG_DADDR		0x008
> +#define NFC_FLAG_SPORT		0x010
> +#define NFC_FLAG_DPORT		0x020
> +#define NFC_FLAG_SPI		0x030
> +#define NFC_FLAG_TOS		0x040
> +#define NFC_FLAG_PROTO		0x080
> +#define NTUPLE_FLAG_VLAN	0x100
> +#define NTUPLE_FLAG_UDEF	0x200
> +#define NTUPLE_FLAG_VETH	0x400
> +
> +struct rule_opts {
> +	const char	*name;
> +	rule_opt_type_t	type;
> +	u32		flag;
> +	int		offset;
> +	int		moffset;
> +};

I think that this ought to be merged with the argument parsing in
ethtool.c, but I won't insist that you do that immedaitely.  However:

[...]
> +static int rxclass_get_ipv4(char *str, __be32 *val)
> +{
> +	if (!strchr(str, '.')) {
> +		unsigned long long v;
> +		int err;
> +
> +		err = rxclass_get_ulong(str, &v, 32);
> +		if (err)
> +			return -1;
> +
> +		*val = htonl((u32)v);
> +
> +		return 0;
> +	}
> +
> +	if (!inet_pton(AF_INET, str, val))
> +		return -1;

There's no need to make a special case for integers.  inet_aton() should
handle all the historically supported IPv4 literal formats.

[...]
> +int rxclass_parse_ruleopts(char **argp, int argc,
> +			   struct ethtool_rx_flow_spec *fsp)
> +{
> +	const struct rule_opts *options;
> +	unsigned char *p = (unsigned char *)fsp;
> +	int i = 0, n_opts, err;
> +	u32 flags = 0;
> +	int flow_type;
> +
> +	if (*argp == NULL || **argp == '\0' || argc < 1)
> +		goto syntax_err;

argc < 1 is sufficient.

> +	if (!strcmp(argp[0], "tcp4"))
> +		flow_type = TCP_V4_FLOW;
> +	else if (!strcmp(argp[0], "udp4"))
> +		flow_type = UDP_V4_FLOW;
> +	else if (!strcmp(argp[0], "sctp4"))
> +		flow_type = SCTP_V4_FLOW;
> +	else if (!strcmp(argp[0], "ah4"))
> +		flow_type = AH_V4_FLOW;
> +	else if (!strcmp(argp[0], "esp4"))
> +		flow_type = ESP_V4_FLOW;
> +	else if (!strcmp(argp[0], "ip4"))
> +		flow_type = IP_USER_FLOW;
> +	else if (!strcmp(argp[0], "ether"))
> +		flow_type = ETHER_FLOW;
> +	else
> +		goto syntax_err;
> +
> +	switch (flow_type) {
> +	case TCP_V4_FLOW:
> +	case UDP_V4_FLOW:
> +	case SCTP_V4_FLOW:
> +		options = rule_nfc_tcp_ip4;
> +		n_opts = ARRAY_SIZE(rule_nfc_tcp_ip4);
> +		break;
> +	case AH_V4_FLOW:
> +	case ESP_V4_FLOW:
> +		options = rule_nfc_esp_ip4;
> +		n_opts = ARRAY_SIZE(rule_nfc_esp_ip4);
> +		break;
> +	case IP_USER_FLOW:
> +		options = rule_nfc_usr_ip4;
> +		n_opts = ARRAY_SIZE(rule_nfc_usr_ip4);
> +		break;
> +	case ETHER_FLOW:
> +		options = rule_nfc_ether;
> +		n_opts = ARRAY_SIZE(rule_nfc_ether);
> +		break;
> +	default:
> +		fprintf(stdout, "Add rule, invalid rule type[%s]\n", argp[0]);

stderr, not stdout

[...]
> +		if (idx == n_opts) {
> +			fprintf(stdout, "Add rule, unreconized option[%s]\n",

Typo: 'unreconized' should be 'unrecognized'.

> +				argp[i]);
> +			return -1;
> +		}
> +	}
> +
> +	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
> +		fsp->flow_type |= FLOW_EXT;
> +
> +	return 0;
> +
> +syntax_err:
> +	fprintf(stdout, "Add rule, invalid syntax\n");

stderr

> +	return -1;
> +}
> 

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

