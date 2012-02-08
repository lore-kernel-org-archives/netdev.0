From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v8 PATCH 3/3] NETFILTER userspace part for target HMARK
Date: Wed, 8 Feb 2012 01:32:10 +0100
Message-ID: <20120208003210.GB29189@1984>
References: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com>
 <1327675303-9059-4-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1327675303-9059-4-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2012 at 03:41:43PM +0100, Hans Schillstrom wrote:
> new file mode 100644
> index 0000000..09d9c75
> --- /dev/null
> +++ b/extensions/libxt_HMARK.c
> @@ -0,0 +1,372 @@
> +/*
> + * Shared library add-on to iptables to add HMARK target support.
> + *
> + * The kernel module calculates a hash value that can be modified by modulus
> + * and an offset. The hash value is based on a direction independent
> + * five tuple: src & dst addr src & dst ports and protocol.
> + * However src & dst port can be masked and are not used for fragmented
> + * packets, ESP and AH don't have ports so SPI will be used instead.
> + * For ICMP error messages the hash mark values will be calculated on
> + * the source packet i.e. the packet caused the error (If sufficient
> + * amount of data exists).
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +#include <stdbool.h>
> +#include <stdio.h>
> +#include <string.h>
> +
> +#include <xtables.h>
> +#include <linux/netfilter/xt_hmark.h>
> +
> +
> +#define DEF_HRAND 0xc175a3b8	/* Default "random" value to jhash */
> +
> +static void HMARK_help(void)
> +{
> +	printf(
> +"HMARK target options, i.e. modify hash calculation by:\n"
> +"  --hmark-method <method>          Overall L3/L4 and fragment behavior\n"
> +"                 L3                Fragment safe, do not use ports or proto\n"
> +"                                   i.e. Fragments don't need special care.\n"
> +"                 L3-4 (Default)    Fragment unsafe, use ports and proto\n"
> +"                                   if defrag off in conntrack\n"
> +"                                      no hmark on any part of a fragment\n"
> +"  Limit/modify the calculated hash mark by:\n"
> +"  --hmark-mod value                nfmark modulus value\n"
> +"  --hmark-offset value             Last action add value to nfmark\n\n"
> +" Fine tuning of what will be included in hash calculation\n"
> +"  --hmark-src-mask length          Source address mask length\n"
> +"  --hmark-dst-mask length          Dest address mask length\n"
> +"  --hmark-sport-mask value         Mask src port with value\n"
> +"  --hmark-dport-mask value         Mask dst port with value\n"
> +"  --hmark-spi-mask value           For esp and ah AND spi with value\n"
> +"  --hmark-sport-set value          OR src port with value\n"
> +"  --hmark-dport-set value          OR dst port with value\n"
> +"  --hmark-spi-set value            For esp and ah OR spi with value\n"
> +"  --hmark-proto-mask value         Mask Protocol with value\n"
> +"  --hmark-rnd                      Initial Random value to hash cacl.\n"
> +" For NAT in IPv4 the original address can be used in the return path.\n"
> +" Make sure to qualify the statement in a proper way when using nat flags\n"
> +"  --hmark-ct-orig-src              Replace src addr with original dst addr\n"
> +"  --hmark-ct-orig-dst              Replace dst addr with original src addr\n"
> +" In many cases hmark can be omitted i.e. --src-mask can be used\n");
> +}
> +
> +#define hi struct xt_hmark_info
> +
> +static const struct xt_option_entry HMARK_opts[] = {
> +	{ .name = "hmark-method",     .type = XTTYPE_STRING, .id = XT_HMARK_METHOD_L3

Make sure you break lines at 80 chars.

This is the convention in the kernel and in user-space netfilter
tools.

> diff --git a/extensions/libxt_HMARK.man b/extensions/libxt_HMARK.man
> new file mode 100644
> index 0000000..d514c8b
> --- /dev/null
> +++ b/extensions/libxt_HMARK.man
> @@ -0,0 +1,88 @@
> +This module does the same as MARK, i.e. set an fwmark, but the mark is based on a hash value.
> +The hash is based on saddr, daddr, sport, dport and proto. The same mark will be produced independent of direction if no masks is set or the same masks is used for src and dest.
> +The hash mark could be adjusted by modulus and finally an offset could be added, i.e the final mark will be within a range.
> +ICMP error will use the the original message for hash calculation not the icmp it self.
> +
> +Note: IPv4 packets with nf_defrag_ipv4 loaded will be defragmented before they reach hmark,
> +      IPv6 nf_defrag is not implemented this way, hence fragmented ipv6 packets will reach hmark.
> +      Default behavior is to completely ignore any fragment if it reach hmark.
> +      --hmark-method L3 is fragment safe since neither ports or L4 protocol field is used.
> +      None of the parameters effect the packet it self only the calculated hash value.
> +
> +.PP
> +Parameters:
> +Short hand methods
> +.TP
> +\fB\-\-hmark\-method\fP \fIL3\fP
> +Do not use L4 protocol field, ports or spi, only Layer 3 addresses, mask length
> +of L3 addresses can still be used. Fragment or not does not matter in
> +this case since only L3 address can be used in calc. of hash value.
> +.TP
> +\fB\-\-hmark\-method\fP \fIL3-4\fP (Default)
> +Include L4 in calculation. of hash value i.e. all masks below are valid.
> +Fragments will be ignored. (i.e no hash value produced)
> +.PP
> +For all masks default is all "1:s", to disable a field use mask 0
> +.TP
> +\fB\-\-hmark\-src\-mask\fP \fIlength\fP
> +The length of the mask to AND the source address with (saddr & value).
> +.TP
> +\fB\-\-hmark\-dst\-mask\fP \fIlength\fP
> +The length of the mask to AND the dest. address with (daddr & value).
> +.TP
> +\fB\-\-hmark\-sport\-mask\fP \fIvalue\fP
> +A 16 bit value to AND the src port with (sport & value).
> +.TP
> +\fB\-\-hmark\-dport\-mask\fP \fIvalue\fP
> +A 16 bit value to AND the dest port with (dport & value).
> +.TP
> +\fB\-\-hmark\-sport\-set\fP \fIvalue\fP
> +A 16 bit value to OR the src port with (sport | value).
> +.TP
> +\fB\-\-hmark\-dport\-set\fP \fIvalue\fP
> +A 16 bit value to OR the dest port with (dport | value).
> +.TP
> +\fB\-\-hmark\-spi\-mask\fP \fIvalue\fP
> +Value to AND the spi field with (spi & value) valid for proto esp or ah.
> +.TP
> +\fB\-\-hmark\-spi\-set\fP \fIvalue\fP
> +Value to OR the spi field with (spi | value) valid for proto esp or ah.
> +.TP
> +\fB\-\-hmark\-proto\-mask\fP \fIvalue\fP
> +An 8 bit value to AND the L4 proto field with (proto & value).
> +.TP
> +\fB\-\-hmark\-rnd\fP \fIvalue\fP
> +A 32 bit initial value for hash calc, default is 0xc175a3b8.
> +.PP
> +Final processing of the mark in order of execution.
> +.TP
> +\fB\-\-hmark\-mod\fP \fIvalue (must be > 0)\fP
> +The easiest way to describe this is:  hash = hash mod <value>
> +.TP
> +\fB\-\-hmark\-offset\fP \fIvalue\fP
> +The easiest way to describe this is:  hash = hash + <value>
> +.PP
> +\fIExamples:\fP
> +.PP
> +Default rule handles all TCP, UDP, SCTP, ESP & AH
> +.IP
> +iptables \-t mangle \-A PREROUTING \-m state \-\-state NEW,ESTABLISHED,RELATED
> + \-j HMARK \-\-hmark-offs 10000 \-\-hmark-mod 10
> +.PP
> +Handle SCTP and hash dest port only and produce a nfmark between 100-119.
> +.IP
> +iptables \-t mangle \-A PREROUTING -p SCTP \-j HMARK \-\-src\-mask 0 \-\-dst\-mask 0
> + \-\-sp\-mask 0 \-\-offset 100 \-\-mod 20
> +.PP
> +No defragment by conntrack, None Fragments will have fwmark 100-119
> +and Fragments will have fwmark 120-139 (based on saddr and daddr only)

I'm not native English speaker, so I understand the limitations of
writing in foreign languages. I'd appreciate if you can give review the
text. This sentence above is hard to understand.

Thank you.
