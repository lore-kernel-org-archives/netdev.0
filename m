From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through
 netlink
Date: Thu, 01 Apr 2004 13:50:48 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401.135048.45446611.yoshfuji@linux-ipv6.org>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
	<200403311007.01702.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, xma@us.ibm.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com
In-Reply-To: <200403311007.01702.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <200403311007.01702.mashirle@us.ibm.com> (at Wed, 31 Mar 2004 10:07:01 -0800), Shirley Ma <mashirle@us.ibm.com> says:

> @@ -350,6 +355,10 @@
>  #define IFA_F_SECONDARY		0x01
>  #define IFA_F_TEMPORARY		IFA_F_SECONDARY
>  
> +#define IFA_F_ADDRESS		0x02
> +#define IFA_F_MULTICAST 	0x04
> +#define IFA_F_ANYCAST		0x08
> +
>  #define IFA_F_DEPRECATED	0x20
>  #define IFA_F_TENTATIVE		0x40
>  #define IFA_F_PERMANENT		0x80

Why do we need IFA_F_MULTICAST?
This is waste of flags.

> -static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
> +static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
> +			   unsigned char flags)
                           unsigned char type)


> +		if (flags & IFA_F_ADDRESS) {

                    type == 0

> +			/* unicast address */
> +			for (ifa = idev->addr_list; ifa;
> +			     ifa = ifa->if_next, ip_idx++) {
> +				if (ip_idx < s_ip_idx)
> +					continue;
> +				if ((err = inet6_fill_ifaddr(skb, ifa, 
> +				    NETLINK_CB(cb->skb).pid, 
> +				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
> +					goto done;
> +			}
> +			/* temp addr */
>  #ifdef CONFIG_IPV6_PRIVACY
> -		for (ifa = idev->tempaddr_list; ifa; 
> -		     ifa = ifa->tmp_next, ip_idx++) {
> -			if (ip_idx < s_ip_idx)
> -				continue;
> -			if ((err = inet6_fill_ifaddr(skb, ifa, 
> -			    NETLINK_CB(cb->skb).pid, 
> -			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
> -				goto done;
> -		}
> +			for (ifa = idev->tempaddr_list; ifa; 
> +			     ifa = ifa->tmp_next, ip_idx++) {
> +				if (ip_idx < s_ip_idx)
> +					continue;
> +				if ((err = inet6_fill_ifaddr(skb, ifa, 
> +				    NETLINK_CB(cb->skb).pid, 
> +				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
> +					goto done;
> +			}
>  #endif
> +		}
> +		if (flags & IFA_F_MULTICAST) {
                    type == IFA_MULTICAST
> +			/* multicast address */
> +			for (ifmca = idev->mc_list; ifmca; 
> +			     ifmca = ifmca->next, ip_idx++) {
> +				if (ip_idx < s_ip_idx)
> +					continue;
> +				if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
> +				    NETLINK_CB(cb->skb).pid, 
> +				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST)) <= 0)
> +					goto done;
> +			}
> +		}
> +		if (flags & IFA_F_ANYCAST) {
                    type == IFA_ANYCAST
> +			/* anycast address */
> +			for (ifaca = idev->ac_list; ifaca;
> +			     ifaca = ifaca->aca_next, ip_idx++) {
> +				if (ip_idx < s_ip_idx)
> +					continue;
> +				if ((err = inet6_fill_ifacaddr(skb, ifaca, 
> +				    NETLINK_CB(cb->skb).pid, 
> +				    cb->nlh->nlmsg_seq, RTM_GETANYCAST)) <= 0) 
> +					goto done;
> +			}
> +		}
>  		read_unlock_bh(&idev->lock);
>  		in6_dev_put(idev);
>  	}
> @@ -2687,6 +2714,25 @@
>  	return skb->len;
>  }
>  
> +static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	unsigned char flag = IFA_F_ADDRESS;
> +	return inet6_dump_addr(skb, cb, flag);
                                        0
> +}
> +
> +static int inet6_dump_ifmcaddr(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	unsigned char flag = IFA_F_MULTICAST;
> +	return inet6_dump_addr(skb, cb, flag);
                                        IFA_MULTICAST
> +}
> +
> +
> +static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	unsigned char flag = IFA_F_ANYCAST;
> +	return inet6_dump_addr(skb, cb, flag);
                                        IFA_ANYCAST
> +}
> +
>  static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
>  {
>  	struct sk_buff *skb;


Of course, we can use switch-case.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
