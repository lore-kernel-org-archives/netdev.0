From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: PATCH: add IP_USER_FLOW to rxntuple interface
Date: Tue, 03 May 2011 08:59:06 -0700
Message-ID: <4DC0264A.2090503@intel.com>
References: <OF20F9D953.0F90C5C5-ON85257885.004A9AEF-85257885.004A9AF3@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Sebastian.Poehn@Belden.com" <Sebastian.Poehn@Belden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab1ECP7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 11:59:07 -0400
In-Reply-To: <OF20F9D953.0F90C5C5-ON85257885.004A9AEF-85257885.004A9AF3@BeldenCDT.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2011 6:34 AM, Sebastian.Poehn@Belden.com wrote:
> I added IP_USER_FLOW to the rx ntuple interface of ethtool which will
> support raw IP traffic classification. If the patch is okay i will
> add the new parameters to the manpage.
>
> Signed-off-by: Sebastian Poehn<sebastian.poehn@belden.com>
>
> --- ethtool/ethtool.c.orig    2011-05-03 11:17:30.457012539 +0200
> +++ ethtool/ethtool.c    2011-05-03 13:24:52.709010424 +0200
> @@ -396,6 +396,12 @@ static int ntuple_psrc_seen = 0;
>   static int ntuple_psrc_mask_seen = 0;
>   static int ntuple_pdst_seen = 0;
>   static int ntuple_pdst_mask_seen = 0;
> +static int ntuple_l4_4_bytes_seen = 0;
> +static int ntuple_l4_4_bytes_mask_seen = 0;
> +static int ntuple_ip_ver_seen = 0;
> +static int ntuple_ip_ver_mask_seen = 0;
> +static int ntuple_ip_proto_seen = 0;
> +static int ntuple_ip_proto_mask_seen = 0;
>   static int ntuple_ether_dst_seen = 0;
>   static int ntuple_ether_dst_mask_seen = 0;
>   static int ntuple_ether_src_seen = 0;
> @@ -423,10 +429,12 @@ typedef enum {
>       CMDL_NONE,
>       CMDL_BOOL,
>       CMDL_S32,
> +    CMDL_U8,
>       CMDL_U16,
>       CMDL_U32,
>       CMDL_U64,
>       CMDL_BE16,
> +    CMDL_BE32,
>       CMDL_IP4,
>       CMDL_STR,
>       CMDL_FLAG,
> @@ -554,6 +562,38 @@ static struct cmdline_info cmdline_ntupl
>       { "action", CMDL_S32,&ntuple_fs.action, NULL },
>   };
>
> +static struct cmdline_info cmdline_ntuple_usr_ip4[] = {
> +    { "src-ip", CMDL_IP4,&ntuple_fs.h_u.usr_ip4_spec.ip4src, NULL,
> +      0,&ntuple_ip4src_seen },
> +    { "src-ip-mask", CMDL_IP4,&ntuple_fs.m_u.usr_ip4_spec.ip4src, NULL,
> +      0,&ntuple_ip4src_mask_seen },
> +    { "dst-ip", CMDL_IP4,&ntuple_fs.h_u.usr_ip4_spec.ip4dst, NULL,
> +      0,&ntuple_ip4dst_seen },
> +    { "dst-ip-mask", CMDL_IP4,&ntuple_fs.m_u.usr_ip4_spec.ip4dst, NULL,
> +      0,&ntuple_ip4dst_mask_seen },
> +    { "l4-data", CMDL_BE32,&ntuple_fs.h_u.usr_ip4_spec.l4_4_bytes, NULL,
> +      0,&ntuple_l4_4_bytes_seen },
> +    { "l4-data-mask", CMDL_BE32,&ntuple_fs.m_u.usr_ip4_spec.l4_4_bytes, NULL,
> +      0,&ntuple_l4_4_bytes_mask_seen },
> +    { "version", CMDL_U8,&ntuple_fs.h_u.usr_ip4_spec.ip_ver, NULL,
> +      0,&ntuple_ip_ver_seen },
> +    { "version-mask", CMDL_U8,&ntuple_fs.m_u.usr_ip4_spec.ip_ver, NULL,
> +      0,&ntuple_ip_ver_mask_seen },
> +    { "iana", CMDL_U8,&ntuple_fs.h_u.usr_ip4_spec.proto, NULL,
> +      0,&ntuple_ip_proto_seen },
> +    { "iana-mask", CMDL_U8,&ntuple_fs.m_u.usr_ip4_spec.proto, NULL,
> +      0,&ntuple_ip_proto_mask_seen },
> +    { "vlan", CMDL_U16,&ntuple_fs.vlan_tag, NULL,
> +      0,&ntuple_vlan_tag_seen },
> +    { "vlan-mask", CMDL_U16,&ntuple_fs.vlan_tag_mask, NULL,
> +      0,&ntuple_vlan_tag_mask_seen },
> +    { "user-def", CMDL_U64,&ntuple_fs.data, NULL,
> +      0,&ntuple_user_def_seen },
> +    { "user-def-mask", CMDL_U64,&ntuple_fs.data_mask, NULL,
> +      0,&ntuple_user_def_mask_seen },
> +    { "action", CMDL_S32,&ntuple_fs.action, NULL },
> +};
> +
>   static struct cmdline_info cmdline_ntuple_ether[] = {
>       { "dst", CMDL_MAC, ntuple_fs.h_u.ether_spec.h_dest, NULL,
>         0,&ntuple_ether_dst_seen },
> @@ -689,6 +729,11 @@ static void parse_generic_cmdline(int ar
>                                  0x7fffffff);
>                       break;
>                   }
> +                case CMDL_U8: {
> +                    u8 *p = info[idx].wanted_val;
> +                    *p = get_uint_range(argp[i], 0, 0xff);
> +                    break;
> +                }
>                   case CMDL_U16: {
>                       u16 *p = info[idx].wanted_val;
>                       *p = get_uint_range(argp[i], 0, 0xffff);
> @@ -714,6 +759,13 @@ static void parse_generic_cmdline(int ar
>                                      0xffff));
>                       break;
>                   }
> +                case CMDL_BE32: {
> +                    u32 *p = info[idx].wanted_val;
> +                    *p = cpu_to_be32(
> +                        get_uint_range(argp[i], 0,
> +                                   0xffffffff));
> +                    break;
> +                }
>                   case CMDL_IP4: {
>                       u32 *p = info[idx].wanted_val;
>                       struct in_addr in;
> @@ -786,6 +838,8 @@ static int rxflow_str_to_type(const char
>           flow_type = AH_ESP_V4_FLOW;
>       else if (!strcmp(str, "sctp4"))
>           flow_type = SCTP_V4_FLOW;
> +    else if (!strcmp(str, "usr4"))
> +        flow_type = IP_USER_FLOW;
>       else if (!strcmp(str, "tcp6"))
>           flow_type = TCP_V6_FLOW;
>       else if (!strcmp(str, "udp6"))
> @@ -1648,6 +1702,23 @@ static void parse_rxntupleopts(int argc,
>           if (!ntuple_ether_proto_seen)
>               ntuple_fs.m_u.ether_spec.h_proto = 0xffff;
>           break;
> +    case IP_USER_FLOW:
> +        parse_generic_cmdline(argc, argp, i + 1,
> +&sntuple_changed,
> +                      cmdline_ntuple_usr_ip4,
> +                      ARRAY_SIZE(cmdline_ntuple_usr_ip4));
> +        if (!ntuple_ip4src_seen)
> +            ntuple_fs.m_u.usr_ip4_spec.ip4src = 0xffffffff;
> +        if (!ntuple_ip4dst_seen)
> +            ntuple_fs.m_u.usr_ip4_spec.ip4dst = 0xffffffff;
> +        if (!ntuple_l4_4_bytes_seen)
> +            ntuple_fs.m_u.usr_ip4_spec.l4_4_bytes = 0xffffffff;
> +        if (!ntuple_ip_ver_seen)
> +            ntuple_fs.m_u.usr_ip4_spec.ip_ver = 0xff;
> +        if (!ntuple_ip_proto_seen)
> +            ntuple_fs.m_u.usr_ip4_spec.proto = 0xff;
> +        ntuple_fs.m_u.tcp_ip4_spec.tos = 0xff;
> +        break;
>       default:
>           fprintf(stderr, "Unsupported flow type \"%s\"\n", argp[i]);
>           exit(106);
>

All of this code doesn't exist after the changes I am making to add 
network flow classifier support to ethtool.  I also believe this is all 
redundant since the updated changes should allow ntuple to use 
IP_USER_FLOW since it already supported in network flow classifier.

Thanks,

Alex
