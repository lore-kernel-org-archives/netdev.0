From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Tue, 22 Feb 2011 12:52:50 -0800
Message-ID: <4D642222.6050202@intel.com>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com> <1298302841.2608.35.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36450 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992Ab1BVUwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 15:52:53 -0500
In-Reply-To: <1298302841.2608.35.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've included my response to your comments below.

Thanks,

Alex

On 2/21/2011 7:40 AM, Ben Hutchings wrote:
> On Thu, 2011-02-10 at 17:18 -0800, Alexander Duyck wrote:
>> From: Santwona Behera<santwona.behera@sun.com>
>>
>> This patch was originally introduced as:
>>    [PATCH 1/3] [ethtool] Add rx pkt classification interface
>>    Signed-off-by: Santwona Behera<santwona.behera@sun.com>
>>    http://patchwork.ozlabs.org/patch/23223/
>>
>> I have updated it to address a number of issues.  As a result I removed the
>> local caching of rules due to the fact that there were memory leaks in this
>> code and the rule manager would consume over 1Mb of space for an 8K table
>> when all that was needed was 1K in order to store which rules were active
>> and which were not.
>>
>> In addition I dropped the use of regions as there were multiple issue found
>> including the fact that the regions were not properly expanding beyond 2
>> and the fact that the regions required reading all of the rules in order to
>> correctly expand beyond 2.  By dropping the regions from the rule manager
>> it is possible to write a much cleaner interface leaving region management
>> to be done by either the driver or by external management scripts.
>>
>> I also added an ethtool bitops interface to allow for simple bit set and
>> test activities since the rule manager can most efficiently store the list
>> of active rules via a bitmap.
> [...]
>> diff --git a/ethtool-bitops.h b/ethtool-bitops.h
>> new file mode 100644
>> index 0000000..7101056
>> --- /dev/null
>> +++ b/ethtool-bitops.h
>> @@ -0,0 +1,25 @@
>> +#ifndef ETHTOOL_BITOPS_H__
>> +#define ETHTOOL_BITOPS_H__
>> +
>> +#define BITS_PER_LONG                __WORDSIZE
>
> This seems to be a glibc-internal macro and I don't think we should use
> it.
>
>> +#define BITS_PER_BYTE                8
>> +#define DIV_ROUND_UP(n, d)   (((n) + (d) - 1) / (d))
>> +#define BITS_TO_LONGS(nr)    DIV_ROUND_UP(nr, BITS_PER_BYTE * sizeof(long))
>
> In fact I notice you don't use it here...

Yeah, as I recall I don't think I trusted that definition of 
BITS_PER_LONG all that much anyway.  I will replace it with 
BITS_PER_BYTE * sizeof(long).

>> +static inline void set_bit(int nr, unsigned long *addr)
>> +{
>> +     addr[nr / BITS_PER_LONG] |= 1UL<<  (nr % BITS_PER_LONG);
>> +}
>> +
>> +static inline void clear_bit(int nr, unsigned long *addr)
>> +{
>> +     addr[nr / BITS_PER_LONG]&= ~(1UL<<  (nr % BITS_PER_LONG));
>> +}
>> +
>> +static __always_inline int test_bit(unsigned int nr, const unsigned long *addr)
>> +{
>> +     return ((1UL<<  (nr % BITS_PER_LONG))&
>> +             (((unsigned long *)addr)[nr / BITS_PER_LONG])) != 0UL;
>> +}
>> +
>> +#endif
>> diff --git a/ethtool-util.h b/ethtool-util.h
>> index f053028..e9300e2 100644
>> --- a/ethtool-util.h
>> +++ b/ethtool-util.h
>> @@ -103,4 +103,17 @@ int sfc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
>>   int st_mac100_dump_regs(struct ethtool_drvinfo *info,
>>                        struct ethtool_regs *regs);
>>   int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
>> +
>> +/* Rx flow classification */
>> +#include<sys/ioctl.h>
>> +#include<net/if.h>
>
> Put #includes at the top of the file, please.

That will be updated in the next patch.

>> +int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
>> +                        struct ethtool_rx_flow_spec *fsp, __u8 *loc_valid);
>> +int rxclass_rule_getall(int fd, struct ifreq *ifr);
>> +int rxclass_rule_get(int fd, struct ifreq *ifr, __u32 loc);
>> +int rxclass_rule_ins(int fd, struct ifreq *ifr,
>> +                  struct ethtool_rx_flow_spec *fsp, __u8 loc_valid);
>> +int rxclass_rule_del(int fd, struct ifreq *ifr, __u32 loc);
>> +
>>   #endif
>> diff --git a/ethtool.8.in b/ethtool.8.in
>> index 133825b..c183a3d 100644
>> --- a/ethtool.8.in
>> +++ b/ethtool.8.in
>> @@ -40,21 +40,36 @@
>>   [\\fB\\$1\\fP\ \\fIN\\fP]
>>   ..
>>   .\"
>> +.\"  .BM - same as above but has a mask field for format "[value N [m N]]"
>> +.\"
>> +.de BM
>> +[\\fB\\$1\\fP\ \\fIN\\fP\ [\\fBm\\fP\ \\fIN\\fP]]
>> +..
>> +.\"
>>   .\"  \(*MA - mac address
>>   .\"
>>   .ds MA \fIxx\fP\fB:\fP\fIyy\fP\fB:\fP\fIzz\fP\fB:\fP\fIaa\fP\fB:\fP\fIbb\fP\fB:\fP\fIcc\fP
>>   .\"
>> +.\"  \(*PA - IP address
>> +.\"
>> +.ds PA \fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP
>> +.\"
>>   .\"  \(*WO - wol flags
>>   .\"
>>   .ds WO \fBp\fP|\fBu\fP|\fBm\fP|\fBb\fP|\fBa\fP|\fBg\fP|\fBs\fP|\fBd\fP...
>>   .\"
>>   .\"  \(*FL - flow type values
>>   .\"
>> -.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBsctp6\fP
>> +.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP||\fBesp4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBesp6\fP|\fBsctp6\fP
>
> This adds two '|' characters between 'ah4' and 'esp4'.

I'll have this fixed for the next patch.

>>   .\"
>>   .\"  \(*HO - hash options
>>   .\"
>>   .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
>> +.\"
>> +.\"  \(*L4 - L4 proto options
>> +.\"
>> +.ds L4 \fBtcp\fP|\fBudp\fP|\fBsctp\fP|\fBah\fP|\fBesp\fP|\fIN\fP
>> +.\"
>>   .\" Start URL.
>>   .de UR
>>   .  ds m1 \\$1\"
>> @@ -224,11 +239,27 @@ ethtool \- query or control network driver and hardware settings
>>   .B ethtool \-n
>>   .I ethX
>>   .RB [ rx-flow-hash \ \*(FL]
>> +.RB [ rx-rings ]
>> +.RB [ rx-class-rule-all ]
>> +.RB [ rx-class-rule
>> +.IR N ]
>
> Should use '.BN'.

It'll be in the next patch.

> [...]
>> diff --git a/ethtool.c b/ethtool.c
>> index 1afdfe4..b624980 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -6,6 +6,7 @@
>>    * Kernel 2.4 update Copyright 2001 Jeff Garzik<jgarzik@mandrakesoft.com>
>>    * Wake-on-LAN,natsemi,misc support by Tim Hockin<thockin@sun.com>
>>    * Portions Copyright 2002 Intel
>> + * Portions Copyright (C) Sun Microsystems 2008
>>    * do_test support by Eli Kupermann<eli.kupermann@intel.com>
>>    * ETHTOOL_PHYS_ID support by Chris Leech<christopher.leech@intel.com>
>>    * e1000 support by Scott Feldman<scott.feldman@intel.com>
>> @@ -14,6 +15,7 @@
>>    * amd8111e support by Reeja John<reeja.john@amd.com>
>>    * long arguments by Andi Kleen.
>>    * SMSC LAN911x support by Steve Glendinning<steve.glendinning@smsc.com>
>> + * Rx Network Flow Control configuration support<santwona.behera@sun.com>
>>    * Various features by Ben Hutchings<bhutchings@solarflare.com>;
>>    *   Copyright 2009, 2010 Solarflare Communications
>>    *
>> @@ -32,7 +34,7 @@
>>   #include<sys/ioctl.h>
>>   #include<sys/stat.h>
>>   #include<stdio.h>
>> -#include<string.h>
>> +#include<strings.h>
>
> No,<string.h>  is standard.

That's fine.  The original patch included this so I just carried it 
forward.  However there are two includes of string.h in this file so 
odds are the second one can just be dropped then.

> [...]
>> @@ -408,6 +425,14 @@ static int msglvl_changed;
>>   static u32 msglvl_wanted = 0;
>>   static u32 msglvl_mask = 0;
>>
>> +static int rx_rings_get = 0;
>> +static int rx_class_rule_get = -1;
>> +static int rx_class_rule_getall = 0;
>> +static int rx_class_rule_del = -1;
>> +static int rx_class_rule_added = 0;
>> +static struct ethtool_rx_flow_spec rx_rule_fs;
>> +static u8 rxclass_loc_valid = 0;
>> +
>>   static enum {
>>        ONLINE=0,
>>        OFFLINE,
> [...]
>> @@ -945,6 +974,23 @@ static void parse_cmdline(int argc, char **argp)
>>                                                rxflow_str_to_type(argp[i]);
>>                                        if (!rx_fhash_get)
>>                                                show_usage(1);
>> +                             } else if (!strcmp(argp[i], "rx-rings")) {
>> +                                     i += 1;
>> +                                     rx_rings_get = 1;
>
> I'm not convinced of the value of a separate rx-rings option/keyword.
> However it's probably worth displaying the number of rings/queues when
> showing other flow hashing and steering/filtering information (the -x
> option does this).

My thought was that it would be useful for determining the number of 
rings prior to adding a rule.  Especially if we have any kind of scripts 
running on top of ethtool so that we can avoid rules that will fail due 
to ring values being greater than the actual number of rings.  I might 
try looking into adding it to the display options for the filters.

>> +                             } else if (!strcmp(argp[i],
>> +                                                "rx-class-rule-all")) {
>> +                                     i += 1;
>> +                                     rx_class_rule_getall = 1;
>> +                             } else if (!strcmp(argp[i], "rx-class-rule")) {
>> +                                     i += 1;
>> +                                     if (i>= argc) {
>> +                                             show_usage(1);
>> +                                             break;
>> +                                     }
>> +                                     rx_class_rule_get =
>> +                                             strtol(argp[i], NULL, 0);
>> +                                     if (rx_class_rule_get<  0)
>> +                                             show_usage(1);
>
> Use get_uint_range(argp[i], 0, INT_MAX).

It'll be in the next patch.

>>                                } else
>>                                        show_usage(1);
>>                                break;
>
> I don't think the same options (-n, -N) should be used both for flow
> hashing and n-tuple flow steering/filtering.  This command-line
> interface and the structure used in the ethtool API just seem to reflect
> the implementation in the niu driver.
>
> (In fact I would much prefer it if the -u and -U options could be used
> for both the rxnfc and rxntuple interfaces.  But I haven't thought about
> how the differences in functionality would be exposed to or hidden from
> the user.)

I was kind of thinking about merging the two interfaces too, but I was 
looking at it more from the perspective of moving away from ntuple more 
towards this newer interface.  My main motivation being that the filter 
display option is so badly broken for ntuple that it would be easier to 
make ntuple a subset of the flow classifier instead of the other way around.

What would you think of using the "flow-type" keyword to indicate legacy 
ntuple support, and then adding something like "class-rule-add", and 
"class-rule-del" to add support for the network flow classifier calls?

Then for display we could add "ntuple-all", "class-rule-all", and 
"class-rule %d" as display options with the default being to go through 
and do both "ntuple-all" and "class-rule-all" if neither are specified. 
  Do you think something like that would work?

>> @@ -978,8 +1024,37 @@ static void parse_cmdline(int argc, char **argp)
>>                                                show_usage(1);
>>                                        else
>>                                                rx_fhash_changed = 1;
>> -                             } else
>> +                             } else if (!strcmp(argp[i],
>> +                                                "rx-class-rule-del")) {
>> +                                     i += 1;
>> +                                     if (i>= argc) {
>> +                                             show_usage(1);
>> +                                             break;
>> +                                     }
>> +                                     rx_class_rule_del =
>> +                                             strtol(argp[i], NULL, 0);
>> +                                     if (rx_class_rule_del<  0)
>> +                                             show_usage(1);
>
> Use get_uint_range(argp[i], 0, INT_MAX).

Will be fixed in the next patch.

>> +                             } else if (!strcmp(argp[i],
>> +                                                "rx-class-rule-add")) {
>> +                                     i += 1;
>> +                                     if (i>= argc) {
>> +                                             show_usage(1);
>> +                                             break;
>> +                                     }
>> +                                     if (rxclass_parse_ruleopts(&argp[i],
>> +                                                                argc - i,
>> +&rx_rule_fs,
>> +&rxclass_loc_valid)<  0) {
>> +                                             show_usage(1);
>> +                                     } else {
>> +                                             i = argc;
>> +                                             rx_class_rule_added = 1;
>> +                                     }
>> +                             } else {
>>                                        show_usage(1);
>> +                             }
>> +
>>                                break;
>>                        }
>>                        if (mode == MODE_SRXFHINDIR) {
>> @@ -1917,9 +1992,12 @@ static int dump_rxfhash(int fhash, u64 val)
>>        case SCTP_V4_FLOW:
>>                fprintf(stdout, "SCTP over IPV4 flows");
>>                break;
>> -     case AH_ESP_V4_FLOW:
>
> I believe this is still a valid type for flow hashing.
>

I just looked and it is since this is something from the original patch. 
  I'm not even really sure why the patch modified this piece except for 
maybe to try and correct the fact that AH and ESP being merged makes it 
much more difficult to separate.  For now what I think I will do is spin 
this off into a separate patch that will add support for displaying 
AH_V4/6_FLOW and add support for setting and displaying ESP_V4/6_FLOW.

>> +     case AH_V4_FLOW:
>>                fprintf(stdout, "IPSEC AH over IPV4 flows");
>>                break;
>> +     case ESP_V4_FLOW:
>> +             fprintf(stdout, "IPSEC ESP over IPV4 flows");
>> +             break;
>>        case TCP_V6_FLOW:
>>                fprintf(stdout, "TCP over IPV6 flows");
>>                break;
>> @@ -1929,9 +2007,12 @@ static int dump_rxfhash(int fhash, u64 val)
>>        case SCTP_V6_FLOW:
>>                fprintf(stdout, "SCTP over IPV6 flows");
>>                break;
>> -     case AH_ESP_V6_FLOW:
>
> Same as for AH_ESP_V4_FLOW.
>

I will just leave the value in for the next patch.

>> +     case AH_V6_FLOW:
>>                fprintf(stdout, "IPSEC AH over IPV6 flows");
>>                break;
>> +     case ESP_V6_FLOW:
>> +             fprintf(stdout, "IPSEC ESP over IPV6 flows");
>> +             break;
>>        default:
>>                break;
>>        }
>> @@ -2911,14 +2992,12 @@ static int do_gstats(int fd, struct ifreq *ifr)
>>        return 0;
>>   }
>>
>> -
>>   static int do_srxclass(int fd, struct ifreq *ifr)
>>   {
>>        int err;
>> +     struct ethtool_rxnfc nfccmd;
>>
>>        if (rx_fhash_changed) {
>> -             struct ethtool_rxnfc nfccmd;
>> -
>>                nfccmd.cmd = ETHTOOL_SRXFH;
>>                nfccmd.flow_type = rx_fhash_set;
>>                nfccmd.data = rx_fhash_val;
>> @@ -2930,6 +3009,20 @@ static int do_srxclass(int fd, struct ifreq *ifr)
>>
>>        }
>>
>> +     if (rx_class_rule_added) {
>> +             err = rxclass_rule_ins(fd, ifr,&rx_rule_fs,
>> +                                    rxclass_loc_valid);
>> +             if (err<  0)
>> +                     fprintf(stderr, "Cannot insert RX classification rule\n");
>> +     }
>> +
>> +     if (rx_class_rule_del>= 0) {
>> +             err = rxclass_rule_del(fd, ifr, rx_class_rule_del);
>> +
>> +             if (err<  0)
>> +                     fprintf(stderr, "Cannot delete RX classification rule\n");
>> +     }
>> +
>>        return 0;
>>   }
>
> This needs to return 1 on error (I know that's an existing bug, but
> don't compound it).
>

This will be fixed for the next patch.

>> @@ -2950,6 +3043,31 @@ static int do_grxclass(int fd, struct ifreq *ifr)
>>                        dump_rxfhash(rx_fhash_get, nfccmd.data);
>>        }
>>
>> +     if (rx_rings_get) {
>> +             struct ethtool_rxnfc nfccmd;
>> +
>> +             nfccmd.cmd = ETHTOOL_GRXRINGS;
>> +             ifr->ifr_data = (caddr_t)&nfccmd;
>> +             err = ioctl(fd, SIOCETHTOOL, ifr);
>> +             if (err<  0)
>> +                     perror("Cannot get RX rings");
>> +             else
>> +                     fprintf(stdout, "%d RX rings available\n",
>> +                             (int)nfccmd.data);
>> +     }
>> +
>> +     if (rx_class_rule_get>= 0) {
>> +             err = rxclass_rule_get(fd, ifr, rx_class_rule_get);
>> +             if (err<  0)
>> +                     fprintf(stderr, "Cannot get RX classification rule\n");
>> +     }
>> +
>> +     if (rx_class_rule_getall) {
>> +             err = rxclass_rule_getall(fd, ifr);
>> +             if (err<  0)
>> +                     fprintf(stderr, "RX classification rule retrieval failed\n");
>> +     }
>> +
>>        return 0;
>>   }
>
> Ditto for this.
>

I'll have it fixed for the next patch.

>> diff --git a/rxclass.c b/rxclass.c
>> new file mode 100644
>> index 0000000..fd01a32
>> --- /dev/null
>> +++ b/rxclass.c
>> @@ -0,0 +1,809 @@
>> +/*
>> + * Copyright (C) 2008 Sun Microsystems, Inc. All rights reserved.
>> + */
>> +#include<stdio.h>
>> +#include<stdint.h>
>> +#include<stddef.h>
>> +#include<stdlib.h>
>> +#include<string.h>
>> +#include<strings.h>
>> +
>> +#include<linux/sockios.h>
>> +#include<arpa/inet.h>
>> +#include "ethtool-util.h"
>> +#include "ethtool-bitops.h"
>> +
>> +/*
>> + * This is a rule manager implementation for ordering rx flow
>> + * classification rules in a longest prefix first match order.
>> + * The assumption is that this rule manager is the only one adding rules to
>> + * the device's hardware classifier.
>> + */
>> +
>> +struct rmgr_ctrl {
>> +     /* slot contains a bitmap indicating which filters are valid */
>> +     unsigned long           *slot;
>> +     __u32                   n_rules;
>> +     __u32                   size;
>> +};
>> +
>> +static struct rmgr_ctrl rmgr;
>> +static int rmgr_init_done = 0;
>> +
>> +#ifndef SIOCETHTOOL
>> +#define SIOCETHTOOL     0x8946
>> +#endif
>
> This definition ought to be moved to ethtool-util.h rather than
> duplicated.

It will be moved in the next patch.

>> +static void rmgr_print_ipv4_rule(struct ethtool_rx_flow_spec *fsp)
>> +{
>> +     char            chan[16];
>> +     char            l4_proto[16];
>> +     __u32           sip, dip, sipm, dipm;
>> +
>> +     sip = ntohl(fsp->h_u.tcp_ip4_spec.ip4src);
>> +     dip = ntohl(fsp->h_u.tcp_ip4_spec.ip4dst);
>> +     sipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4src);
>> +     dipm = ntohl(fsp->m_u.tcp_ip4_spec.ip4dst);
>> +
>> +     if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
>> +             sprintf(chan, "Rx Ring [%d]", (int)fsp->ring_cookie);
>> +     else
>> +             sprintf(chan, "Discard");
>> +
>> +     switch (fsp->flow_type) {
>> +     case TCP_V4_FLOW:
>> +     case UDP_V4_FLOW:
>> +     case SCTP_V4_FLOW:
>> +     case AH_V4_FLOW:
>> +     case ESP_V4_FLOW:
>> +     case IP_USER_FLOW:
>> +             fprintf(stdout,
>> +                     "      IPv4 Rule:  ID[%d] Target[%s]\n"
>> +                     "      IP src addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n"
>> +                     "      IP dst addr[%d.%d.%d.%d] mask[%d.%d.%d.%d]\n"
>> +                     "      IP TOS[0x%x] mask[0x%x]\n",
>
> To be consistent with other ethtool output, this should use colons
> rather than square brackets to separate field names and values.
>

I'll have that updated for the next patch.

> [...]
>> +int rxclass_parse_ruleopts(char **optstr, int opt_cnt,
>> +                        struct ethtool_rx_flow_spec *fsp,
>> +                        u_int8_t *loc_valid)
>> +{
>> +     int i = 0;
>> +
>> +     u_int8_t discard, ring_set;
>> +     u_int32_t ipsa, ipsm, ipda, ipdm, spi, spim;
>> +     u_int16_t sp, spm, dp, dpm;
>> +     u_int8_t ip_ver, proto, tos, tm;
>> +     struct in_addr in_addr;
>> +
>> +     if (*optstr == NULL || **optstr == '\0' || opt_cnt<  2) {
>> +             fprintf(stdout, "Add rule, invalid syntax\n");
>> +             return -1;
>> +     }
>> +
>> +     bzero(fsp, sizeof(struct ethtool_rx_flow_spec));
>> +     ipsa = ipda = ipsm = ipdm = spi = spim = 0x0;
>> +     sp = dp = spm = dpm = 0x0;
>> +     ip_ver = proto = tos = tm = 0x0;
>> +     discard = ring_set = 0;
>> +
>> +     if (!strcmp(optstr[i], "ip4")) {
>> +             ip_ver = ETH_RX_NFC_IP4;
>> +     } else if (!strcmp(optstr[i], "ip6")) {
>> +             fprintf(stdout, "IPv6 not yet implemented\n");
>> +             return -1;
>> +     } else {
>> +             fprintf(stdout, "Add rule, invalid syntax for IP version\n");
>> +             return -1;
>> +     }
>> +
>> +     i++;
>> +
>> +     switch (ip_ver) {
>> +     case ETH_RX_NFC_IP4:
>> +             if (!strcmp(optstr[i], "tcp"))
>> +                     fsp->flow_type = TCP_V4_FLOW;
>> +             else if (!strcmp(optstr[i], "udp"))
>> +                     fsp->flow_type = UDP_V4_FLOW;
>> +             else if (!strcmp(optstr[i], "sctp"))
>> +                     fsp->flow_type = SCTP_V4_FLOW;
>> +             else if (!strcmp(optstr[i], "ah"))
>> +                     fsp->flow_type = AH_V4_FLOW;
>> +             else if (!strcmp(optstr[i], "esp"))
>> +                     fsp->flow_type = ESP_V4_FLOW;
>> +             break;
>> +     default:
>> +             fprintf(stdout, "Add rule, Invalid IP version %d\n", ip_ver);
>> +                     return -1;
>> +     }
>> +
>> +     if (fsp->flow_type == 0) {
>> +             proto = (u_int8_t)strtoul(optstr[i], (char **)NULL, 0);
>> +             if (proto != 0) {
>> +                     fprintf(stdout, "Add rule, user defined proto %d\n",
>> +                             proto);
>> +                     fsp->flow_type = IP_USER_FLOW;
>> +                     fsp->h_u.usr_ip4_spec.proto = proto;
>> +                     fsp->h_u.usr_ip4_spec.ip_ver = ip_ver;
>> +             } else {
>> +                     fprintf(stdout, "Add rule, invalid IP proto %s\n",
>> +                             optstr[i]);
>> +                     return -1;
>> +             }
>> +     }
>> +
>> +     for (i = 2; i<  opt_cnt;) {
>> +             if (!strcmp(optstr[i], "tos")) {
>> +                     tos = (u_int8_t)strtoul(optstr[i+1], (char **)NULL,
>> +                                              0);
>> +                     tm = 0xff;
>> +                     fsp->h_u.tcp_ip4_spec.tos = tos;
>> +
>> +                     i += 2;
>> +                     if (opt_cnt>  (i+1)) {
>> +                             if (!strcmp(optstr[i], "m")) {
>> +                                     tm = (u_int8_t)strtoul(optstr[i+1],
>> +                                                            (char **)NULL,
>> +                                                            16);
>> +                                     i += 2;
>> +                             }
>> +                     }
>> +                     fsp->m_u.tcp_ip4_spec.tos = tm;
>> +             } else if (!strcmp(optstr[i], "sip")) {
> [...]
>
> These keyword names must be made consistent with those used for the -U
> (--config-ntuple) option.
>

I will update the names to be consistent with the ntuple options, 
however I would prefer to keep the option of short-cutting the mask via 
the "m" value.  It will not be hard to make it support both since the 
pattern would be to test for either "m" or "%s-mask".

> Also, they can be parsed much more concisely using the new option types
> I defined a while back for struct cmdline_info.
>

I'm already looking into using something like the cmdline_info to do the 
parsing, however one thing I would like to retain is the mask setting as 
a part of setting the value.  Also since rxclass is being passed a 
pointer it is going to have to work with relative offsets instead of 
fixed values for the location of the fields within the structure.

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>

