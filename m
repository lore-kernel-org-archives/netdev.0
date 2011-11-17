From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [net-next] iproute2: Add new command to IP link to enable/disable
 VF spoof check
Date: Thu, 17 Nov 2011 15:39:32 -0800
Message-ID: <4EC59B34.4080501@intel.com>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14681 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab1KQXjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 18:39:46 -0500
In-Reply-To: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/25/2011 1:23 AM, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> Add IP link command parsing for VF spoof checking enable/disable
>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Stephen,

I don't see that this patch was ever applied to your tree.  Was there 
some problem with it that I missed?  Maybe I'm looking at the wrong tree?

Was just wondering...

Regards,

- Greg

> ---
> include/linux/if_link.h | 7 +++++++
> ip/ipaddress.c | 6 ++++++
> ip/iplink.c | 15 +++++++++++++++
> man/man8/ip.8 | 4 +++-
> 4 files changed, 31 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 304c44f..e421f60 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -277,6 +277,7 @@ enum {
> IFLA_VF_MAC, /* Hardware queue specific attributes */
> IFLA_VF_VLAN,
> IFLA_VF_TX_RATE, /* TX Bandwidth Allocation */
> + IFLA_VF_SPOOFCHK, /* Spoof Checking on/off switch */
> __IFLA_VF_MAX,
> };
>
> @@ -298,12 +299,18 @@ struct ifla_vf_tx_rate {
> __u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
> };
>
> +struct ifla_vf_spoofchk {
> + __u32 vf;
> + __u32 setting;
> +};
> +
> struct ifla_vf_info {
> __u32 vf;
> __u8 mac[32];
> __u32 vlan;
> __u32 qos;
> __u32 tx_rate;
> + __u32 spoofchk;
> };
>
> /* VF ports management section
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 85f05a2..7e6ac50 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -197,6 +197,7 @@ static void print_vfinfo(FILE *fp, struct rtattr
> *vfinfo)
> struct ifla_vf_mac *vf_mac;
> struct ifla_vf_vlan *vf_vlan;
> struct ifla_vf_tx_rate *vf_tx_rate;
> + struct ifla_vf_spoofchk *vf_spoofchk;
> struct rtattr *vf[IFLA_VF_MAX+1];
> SPRINT_BUF(b1);
>
> @@ -210,6 +211,7 @@ static void print_vfinfo(FILE *fp, struct rtattr
> *vfinfo)
> vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
> vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
> vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
> + vf_spoofchk = RTA_DATA(vf[IFLA_VF_SPOOFCHK]);
>
> fprintf(fp, "\n vf %d MAC %s", vf_mac->vf,
> ll_addr_n2a((unsigned char *)&vf_mac->mac,
> @@ -220,6 +222,10 @@ static void print_vfinfo(FILE *fp, struct rtattr
> *vfinfo)
> fprintf(fp, ", qos %d", vf_vlan->qos);
> if (vf_tx_rate->rate)
> fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
> + if (vf_spoofchk->setting)
> + fprintf(fp, ", spoof checking on");
> + else
> + fprintf(fp, ", spoof checking off");
> }
>
> int print_linkinfo(const struct sockaddr_nl *who,
> diff --git a/ip/iplink.c b/ip/iplink.c
> index e5325a6..f4a5243 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -71,7 +71,10 @@ void iplink_usage(void)
> fprintf(stderr, " [ alias NAME ]\n");
> fprintf(stderr, " [ vf NUM [ mac LLADDR ]\n");
> fprintf(stderr, " [ vlan VLANID [ qos VLAN-QOS ] ]\n");
> +
> fprintf(stderr, " [ rate TXRATE ] ] \n");
> +
> + fprintf(stderr, " [ spoofchk { on | off} ] ] \n");
> fprintf(stderr, " [ master DEVICE ]\n");
> fprintf(stderr, " [ nomaster ]\n");
> fprintf(stderr, " ip link show [ DEVICE | group GROUP ]\n");
> @@ -228,6 +231,18 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
> ivt.vf = vf;
> addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
>
> + } else if (matches(*argv, "spoofchk") == 0) {
> + struct ifla_vf_spoofchk ivs;
> + NEXT_ARG();
> + if (matches(*argv, "on") == 0)
> + ivs.setting = 1;
> + else if (matches(*argv, "off") == 0)
> + ivs.setting = 0;
> + else
> + invarg("Invalid \"spoofchk\" value\n", *argv);
> + ivs.vf = vf;
> + addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
> +
> } else {
> /* rewind arg */
> PREV_ARG();
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index 27993a4..cd7b97a 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -100,7 +100,9 @@ ip \- show / manipulate routing, devices, policy
> routing and tunnels
> .B qos
> .IR VLAN-QOS " ] ] ["
> .B rate
> -.IR TXRATE " ] |"
> +.IR TXRATE " ] ["
> +.B spoofchk { on | off }
> +] |
> .br
> .B master
> .IR DEVICE
