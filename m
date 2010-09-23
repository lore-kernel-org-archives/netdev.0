From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/8] net: Allow setting the network namespace by fd
Date: Thu, 23 Sep 2010 09:03:37 -0700
Message-ID: <m1k4mch2g6.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m1hbhgq1v1.fsf@fess.ebiederm.org>
	<1285234885.2864.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1285234885.2864.1.camel@edumazet-laptop> (Eric Dumazet's message
	of "Thu, 23 Sep 2010 11:41:25 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le jeudi 23 septembre 2010 =C3=A0 01:51 -0700, Eric W. Biederman a =C3=
=A9crit :
>> Take advantage of the new abstraction and allow network devices
>> to be placed in any network namespace that we have a fd to talk
>> about.
>>=20
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  include/linux/if_link.h     |    1 +
>>  include/net/net_namespace.h |    1 +
>>  net/core/net_namespace.c    |   26 ++++++++++++++++++++++++++
>>  net/core/rtnetlink.c        |    4 +++-
>>  4 files changed, 31 insertions(+), 1 deletions(-)
>>=20
>> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>> index 2fc66dd..ae73d5e 100644
>> --- a/include/linux/if_link.h
>> +++ b/include/linux/if_link.h
>> @@ -116,6 +116,7 @@ enum {
>>  	IFLA_STATS64,
>>  	IFLA_VF_PORTS,
>>  	IFLA_PORT_SELF,
>> +	IFLA_NET_NS_FD,
>>  	__IFLA_MAX
>>  };
>> =20
>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace=
=2Eh
>> index bd10a79..68672ce 100644
>> --- a/include/net/net_namespace.h
>> +++ b/include/net/net_namespace.h
>> @@ -114,6 +114,7 @@ static inline struct net *copy_net_ns(unsigned l=
ong flags, struct net *net_ns)
>>  extern struct list_head net_namespace_list;
>> =20
>>  extern struct net *get_net_ns_by_pid(pid_t pid);
>> +extern struct net *get_net_ns_by_fd(int pid);
>> =20
>>  #ifdef CONFIG_NET_NS
>>  extern void __put_net(struct net *net);
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index 581a088..a9b54a7 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -8,6 +8,8 @@
>>  #include <linux/idr.h>
>>  #include <linux/rculist.h>
>>  #include <linux/nsproxy.h>
>> +#include <linux/proc_fs.h>
>> +#include <linux/file.h>
>>  #include <net/net_namespace.h>
>>  #include <net/netns/generic.h>
>> =20
>> @@ -341,6 +343,30 @@ struct net *get_net_ns_by_pid(pid_t pid)
>>  }
>>  EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
>> =20
>> +struct net *get_net_ns_by_fd(int fd)
>> +{
>> +	struct proc_inode *ei;
>> +	struct file *file;
>> +	struct net *net;
>> +
>> +	file =3D NULL;
>> +	net =3D ERR_PTR(-EINVAL);
>> +	file =3D proc_ns_fget(fd);
>> +	if (!fd)
>> +		goto out;
>> +		return ERR_PTR(-EINVAL);
>> +
>> +	ei =3D PROC_I(file->f_dentry->d_inode);
>> +	if (ei->ns_ops !=3D &netns_operations)
>> +		goto out;
>> +
>> +	net =3D get_net(ei->ns);
>> +out:
>> +	if (file)
>> +		fput(file);
>> +	return net;
>> +}
>> +
>>  static int __init net_ns_init(void)
>>  {
>>  	struct net_generic *ng;
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index f78d821..771d8be 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -1003,6 +1003,8 @@ struct net *rtnl_link_get_net(struct net *src_=
net, struct nlattr *tb[])
>>  	 */
>>  	if (tb[IFLA_NET_NS_PID])
>>  		net =3D get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
>> +	else if (tb[IFLA_NET_NS_FD])
>> +		net =3D get_net_ns_by_fd(nla_get_u32(tb[IFLA_NET_NS_FD]));
>>  	else
>>  		net =3D get_net(src_net);
>>  	return net;
>> @@ -1077,7 +1079,7 @@ static int do_setlink(struct net_device *dev, =
struct ifinfomsg *ifm,
>>  	int send_addr_notify =3D 0;
>>  	int err;
>> =20
>> -	if (tb[IFLA_NET_NS_PID]) {
>> +	if (tb[IFLA_NET_NS_PID] || tb[IFLA_NET_NS_FD]) {
>>  		struct net *net =3D rtnl_link_get_net(dev_net(dev), tb);
>>  		if (IS_ERR(net)) {
>>  			err =3D PTR_ERR(net);
>
> You probably want to add following chunk :

Thanks fixed.

Eric

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b2a718d..35bb6de 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -927,6 +927,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] =3D=
 {
>  	[IFLA_LINKMODE]		=3D { .type =3D NLA_U8 },
>  	[IFLA_LINKINFO]		=3D { .type =3D NLA_NESTED },
>  	[IFLA_NET_NS_PID]	=3D { .type =3D NLA_U32 },
> +	[IFLA_NET_NS_FD]	=3D { .type =3D NLA_U32 },
>  	[IFLA_IFALIAS]	        =3D { .type =3D NLA_STRING, .len =3D IFALIAS=
Z-1 },
>  	[IFLA_VFINFO_LIST]	=3D {. type =3D NLA_NESTED },
>  	[IFLA_VF_PORTS]		=3D { .type =3D NLA_NESTED },
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
