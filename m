From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 17:23:40 -0400
Message-ID: <5085B95C.3060603@hp.com>
References: <508123AC.5080208@parallels.com> <50858ABD.2000206@hp.com> <5085AC71.7060904@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:5821 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab2JVVXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:23:42 -0400
In-Reply-To: <5085AC71.7060904@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2012 04:28 PM, Pavel Emelyanov wrote:
> On 10/22/2012 10:04 PM, Brian Haley wrote:
>> On 10/19/2012 05:55 AM, Pavel Emelyanov wrote:
>>> The SO_BINDTODEVICE option is the only SOL_SOCKET one that can be set, but
>>> cannot be get via sockopt API. The only way we can find the device id a
>>> socket is bound to is via sock-diag interface. But the diag works only on
>>> hashed sockets, while the opt in question can be set for yet unhashed one.
>>>
>>> That said, in order to know what device a socket is bound to (we do want
>>> to know this in checkpoint-restore project) I propose to make this option
>>> getsockopt-able and report the respective device index.
>>>
>>> Another solution to the problem might be to teach the sock-diag reporting
>>> info on unhashed sockets. Should I go this way instead?
>>>
>>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>>
>>> ---
>>>
>>> diff --git a/net/core/sock.c b/net/core/sock.c
>>> index 8a146cf..c49412c 100644
>>> --- a/net/core/sock.c
>>> +++ b/net/core/sock.c
>>> @@ -1074,6 +1074,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>>>  	case SO_NOFCS:
>>>  		v.val = sock_flag(sk, SOCK_NOFCS);
>>>  		break;
>>> +	case SO_BINDTODEVICE:
>>> +		v.val = sk->sk_bound_dev_if;
>>> +		break;
>>>  	default:
>>>  		return -ENOPROTOOPT;
>>>  	}
>>
>> Doesn't this make the set and get non-symmetrical?  For example, setsockopt()
>> would take "eth0", but getsockopt() would return 2.
> 
> It will, but since device name and index are two equal device "IDs" I assumed
> it would be OK.
> 
> However, some comments inline.
> 
>> The following patch would return a string, or -ENODEV if not set.

Sorry, my description is not quite right, this should return something like this
to be correct:

  0 on success
    optlen zero if interface not set
    optlen > zero if set and optval filled-in

  -errno on failure

>> +static int sock_getbindtodevice(struct sock *sk, char __user *optval,
>> +				int __user *optlen, int len)
>> +{
>> +	int ret = -ENOPROTOOPT;
>> +#ifdef CONFIG_NETDEVICES
>> +	struct net *net = sock_net(sk);
>> +	struct net_device *dev;
>> +	char devname[IFNAMSIZ];
>> +
>> +	ret = 0;
>> +	if (sk->sk_bound_dev_if == 0)
>> +		goto out;
> 
> It will return 0 if device is not set, thus making it impossible to detect
> this situation.

See below.

>> +	ret = -EINVAL;
>> +	if (len < IFNAMSIZ)
>> +		goto out;
>> +	if (len > IFNAMSIZ)
>> +		len = IFNAMSIZ;
>> +
>> +	rcu_read_lock();
>> +	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
>> +	if (dev)
>> +		strcpy(dev->name, devname);
>> +	rcu_read_unlock();
>> +	ret = -ENODEV;
>> +	if (!dev)
>> +		goto out;
>> +
>> +	ret = -EFAULT;
>> +	if (copy_to_user(optval, devname, len))
>> +		goto out;
>> +
>> +	if (put_user(len, optlen))
>> +		goto out;
> 
> What's the point in reporting IFNAMSIZ to the userspace always, taking
> into account that this constant is exported there anyway?

I should have put an RFC on the patch :)

In the case that there is no interface, the length returned would be zero,
indicating nothing was there.

I can post another version.

-Brian
