From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net iproute2 v2 1/2] mpls: always set type as RTN_UNICAST
 for route add/deletes
Date: Wed, 27 May 2015 20:59:22 +0100
Message-ID: <5566221A.5020001@brocade.com>
References: <1432751825-40804-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<vivek@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:13432 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbbE0UBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 16:01:10 -0400
In-Reply-To: <1432751825-40804-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/05/15 19:37, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Kernel expects type RTN_UNICAST for mpls route/dels
>
> Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   ip/iproute.c |    5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 670a4c6..71c088b 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -803,6 +803,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   	int scope_ok = 0;
>   	int table_ok = 0;
>   	int raw = 0;
> +	int type_ok = 0;
>
>   	memset(&req, 0, sizeof(req));
>
> @@ -1095,6 +1096,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   			    rtnl_rtntype_a2n(&type, *argv) == 0) {
>   				NEXT_ARG();
>   				req.r.rtm_type = type;
> +				type_ok = 1;
>   			}
>
>   			if (matches(*argv, "help") == 0)
> @@ -1160,6 +1162,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   		}
>   	}
>
> +	if (!type_ok && req.r.rtm_family == AF_MPLS)
> +		req.r.rtm_type = RTN_UNICAST;
> +
>   	if (req.r.rtm_family == AF_UNSPEC)
>   		req.r.rtm_family = AF_INET;
>
>

There is this block of code near the start of iproute_modify that sets 
req.r.rtm_type in the add/modify cases:

         if (cmd != RTM_DELROUTE) {
                 req.r.rtm_protocol = RTPROT_BOOT;
                 req.r.rtm_scope = RT_SCOPE_UNIVERSE;
                 req.r.rtm_type = RTN_UNICAST;
         }

How about doing similar for the mpls delete case? This would avoid the 
need to track if the type has been set and would also make the way 
rtm_type is set in the delete case as close as possible to that in the 
add/modify cases.

Thanks,
Rob
