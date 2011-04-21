From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v4 3/5] sctp: Add socket option operation for Auto-ASCONF
Date: Thu, 21 Apr 2011 16:11:08 +0900
Message-ID: <2E471FD6-4AF9-44EB-AC63-C74516B4B5FD@sfc.wide.ad.jp>
References: <B0DA9A05-D070-4878-968A-33F41E744463@sfc.wide.ad.jp> <4DAFB93F.9060704@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:46323 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753037Ab1DUHLK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 03:11:10 -0400
In-Reply-To: <4DAFB93F.9060704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

one question inline 
>> 
>> 
>> +/*
>> + * 8.1.23 SCTP_AUTO_ASCONF
>> + *
>> + * This option will enable or disable the use of the automatic generation of
>> + * ASCONF chunks to add and delete addresses to an existing association.  Note
>> + * that this option has two caveats namely: a) it only affects sockets that
>> + * are bound to all addresses available to the SCTP stack, and b) the system
>> + * administrator may have an overriding control that turns the ASCONF feature
>> + * off no matter what setting the socket option may have.
>> + * This option expects an integer boolean flag, where a non-zero value turns on
>> + * the option, and a zero value turns off the option.
>> + * Note. In this implementation, socket operation overrides default parameter
>> + * being set by sysctl as well as FreeBSD implementation
>> + */
> 
> I see:
> b) the system administrator may have an overriding control
> that turns the ASCONF feature off no matter what setting the socket
> option may have.
> 
> You have not add this support?
> 
> To support this, we may change the sysctl auto_sctp_asconf's logic.
> If auto_asconf_enable == 1, we can use auto_asconf, if it is false,
> turns the ASCONF feature off no matter what setting the socket
> option may have. Or intrudce other sysctl to do the orig thing which
> auto_asconf_enable do?
> 
If we implement a feature to disable auto_asconf anyway, we would introduce two sysctl parameters: sctp_default_auto_asconf (just works as current sctp_auto_asconf_enable) and sctp_disable_auto_asconf.  
sctp_disable_auto_asconf should be prioritized from sctp_default_auto_asconf==1.   
I think we should allow the application to enable auto_asconf individually via setsockopt() when the default_auto_asconf is off, unless the disable_auto_asconf is on by system administrator.  

I personally think just defining auto_asconf_enable is ok, because same behavior as FreeBSD would be acceptable.  
But for future implementation of sctp_disable_auto_asconf, at least change the param name to default_auto_asconf would be better.  
Do you think force disabling auto_asconf by sysctl is somehow useful?
I agree if you think so, and will implement quickly.    
> 
>> +static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
>> +					unsigned int optlen)
>> +{
>> +	int val;
>> +	struct sctp_sock *sp = sctp_sk(sk);
>> +
>> +	if (optlen < sizeof(int))
>> +		return -EINVAL;
>> +	if (get_user(val, (int __user *)optval))
>> +		return -EFAULT;
>> +	if (!sctp_is_ep_boundall(sk) && val)
>> +		return -EINVAL;
>> +	if ((val && sp->do_auto_asconf) || (!val && !sp->do_auto_asconf))
>> +		return 0;
>> +
>> +	if (val == 0 && sp->do_auto_asconf) {
>> +		list_del(&sp->auto_asconf_list);
>> +		sp->do_auto_asconf = 0;
>> +	} else if (val && !sp->do_auto_asconf) {
>> +		list_add_tail(&sp->auto_asconf_list,
>> +		    &sctp_auto_asconf_splist);
>> +		sp->do_auto_asconf = 1;
>> +	}
>> +	return 0;
>> +}
>> +
>> 
>> /* API 6.2 setsockopt(), getsockopt()
>>  *
>> @@ -3488,6 +3528,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
>> 	case SCTP_AUTH_DELETE_KEY:
>> 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
>> 		break;
>> +	case SCTP_AUTO_ASCONF:
>> +		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
>> +		break;
>> 	default:
>> 		retval = -ENOPROTOOPT;
>> 		break;
>> @@ -5283,6 +5326,28 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
>> 	return 0;
>> }
>> 
>> +/*
>> + * 8.1.23 SCTP_AUTO_ASCONF
>> + * See the corresponding setsockopt entry as description
>> + */
>> +static int sctp_getsockopt_auto_asconf(struct sock *sk, int len,
>> +				   char __user *optval, int __user *optlen)
>> +{
>> +	int val = 0;
>> +
>> +	if (len < sizeof(int))
>> +		return -EINVAL;
>> +
>> +	len = sizeof(int);
>> +	if (sctp_sk(sk)->do_auto_asconf && sctp_is_ep_boundall(sk))
>> +		val = 1;
>> +	if (put_user(len, optlen))
>> +		return -EFAULT;
>> +	if (copy_to_user(optval, &val, len))
>> +		return -EFAULT;
>> +	return 0;
>> +}
>> +
>> SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
>> 				char __user *optval, int __user *optlen)
>> {
>> @@ -5415,6 +5480,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
>> 	case SCTP_GET_ASSOC_NUMBER:
>> 		retval = sctp_getsockopt_assoc_number(sk, len, optval, optlen);
>> 		break;
>> +	case SCTP_AUTO_ASCONF:
>> +		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
>> +		break;
>> 	default:
>> 		retval = -ENOPROTOOPT;
>> 		break;
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 

