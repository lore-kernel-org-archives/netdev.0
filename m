From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Wed, 23 Jul 2003 15:32:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1F0CF7.5020909@us.ibm.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>	<Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com> <20030723031351.4e9db07c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723031351.4e9db07c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

> 1) Remove "void *sysctl;" from ipv6_devconf, move it into
>    inet6_dev ie. "void *cnf_sysctl;" update all code users.

There is one problem with this that I am not able to figure out, perhaps I am
overlooking it. addrconf_sysctl_register() gets called for ipv6_devconf_dflt,
but there is no inet6_dev for this configuration, so is it possible to move the
sysctl up (there is no 'up' :-). I don't want to create a dummy inet6_dev for
this. One way is to embed the actual config structure as follows :

struct ipv6_devconf {
	void *sysctl;
	struct {
		forwarding;
		hop_limit;
		...
	} u;
};
and follow it up with #defines for all the elements, etc. Then I can use
sizeof(ipv6_devconf.u) without this problem. Another way to do this is using
pointer arithmetic :
	RTA_PUT(skb, IFLA_INET6_CONF, &idev->cnf.sysctl-&idev->cnf.forwarding,
			&idev->cnf);
(guess you may not like it based on your statement "pointers in it which makes
usage sloppy").

I also noticed there is no sysctl_register for ipv6_devconf, but there is a
unregister for that conf. Is that correct ?

> 2) Move "struct ipv6_devconf" into some linux/*.h ipv6 header
>    usable by users.  Use an existing one if possible.  Then
>    make sure net/if_inet6.h includes this thing.

The only two ipv6 specific files in linux are ipv6.h and ipv6_route.h, neither
are appropriate for sysctl stuff I think. So should I create a new file like the
one for ipv4_devconf exists in inetdevice.h ?

> 3) Change "int" members of struct "ipv6_devconf" to "s32".

All members (except use_tempaddr) seem to be >=0, should I change the definition
to __u32 instead ? I am OK either way, just wondering which is the right way to
do this.

Thanks,

- KK
