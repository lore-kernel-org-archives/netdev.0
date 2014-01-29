From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Wed, 29 Jan 2014 17:04:12 +0100
Message-ID: <52E9267C.90403@6wind.com>
References: <20140128205756.074448668@goodmis.org>	<52E8E025.2060803@6wind.com> <20140129075745.4227a2ed@gandalf.local.home>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140129075745.4227a2ed@gandalf.local.home>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 29/01/2014 13:57, Steven Rostedt a =C3=A9crit :
> On Wed, 29 Jan 2014 12:04:05 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Le 28/01/2014 21:57, Steven Rostedt a =C3=A9crit :
>>> At Red Hat we base our real-time kernel off of 3.10.27 and do lots =
of
>>> stress testing on that kernel. This has discovered some bugs that w=
e
>>> can hit with the vanilla 3.10.27 kernel (no -rt patches applied).
>>>
>>> I sent out a bug fix that can cause a crash with the current 3.10.2=
7
>>> when you add and then remove the sit module. That patch is obsolete=
d by
>>> these patches, as that patch was not enough.
>> Can you explain a bit more which problem remains after that patch?
>> I wonder if a problem remains also with ip6_tunnel.ko (net/ipv6/ip6_=
tunnel.c),
>> the same problem was spotted into this module.
>
> Hmm, OK it may only need the first version of the patch. It was one o=
f
> those cases where it didn't fix the second bug, so we added the full
> patch as well. Then we found the second bug but never tried all the
> tests with the smaller version of the patch. I'll put back the first
> patch and then ask our QA to retest it with the older version and the
> other patch.
>
>>
>>>
>>> A previous patch that was backported:
>>>
>>>     Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5
>>>     sit: allow to use rtnl ops on fb tunnel
>>>
>>> Had a depenency on commit 5e6700b3bf98 ("sit: add support of x-netn=
s")
>>> which was not backported. The dependency was only on part of that
>>> commit which is what I backported.
>> I cannot comment directly the patch, it was an attachement, hence I =
put my
>
> It's not really an attachment. It was sent with quilt mail, which onl=
y
> makes it look like one. What mail client are you using? mutt, alpine,
> evolution, claws-mail, and thunderbird all show it as a normal patch.
> I do know that k9-mail on android makes it into an attachment.
Thunderbird. The patch was show as a normal aptch, but when I do "reply=
 all", I
get an empty mail.

>
>> comments here.
>> In patch 0001-sit-Unregister-sit-devices-with-rtnl_link_ops.patch, I=
 wonder how
>> 'if (dev_net(t->dev) !=3D net)' can be wrong. If commit 5e6700b3bf98=
 ("sit: add
>> support of x-netns") has not been backported, this test is always tr=
ue.
>
> Should it just be removed then? This has fixed our bugs, but perhaps =
it
> opened new ones we haven't detected yet. I can remove the if and
> unregister and see if it still works. Or perhaps calling unregister a=
ll
> the time isn't bad.
Ok, I've think a bit more to this problem. First, let's explain it.

rmmod sit
=3D> sit_cleanup()
   =3D> rtnl_link_unregister()
     =3D> __rtnl_kill_links()
       =3D> for_each_netdev(net, dev) {
            if (dev->rtnl_link_ops =3D=3D ops)
               ops->dellink(dev, &list_kill);
          }
  **at this point, the FB device is deleted (and all sit tunnels)**

   =3D> unregister_pernet_device()
     =3D> unregister_pernet_operations()
       =3D> ops_exit_list()
         =3D> sit_exit_net()
           =3D> sit_destroy_tunnels()
              in this function, no tunnel is found
           unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
   ** second deletion, here is the bug **

Now, what happen on netns deletion with the previous patch? Only sit_ex=
it_net()
will be called, hence with the previous patch, the fb device will not b=
e
destroyed, netns will leak.

Your patch serie seems to be the good way to go (note that patch 1/2 do=
es not
compile) but I think the fix is smaller because we don't have x-netns.

Here is my proposal, if you agree, I will send the same patch for ip6_t=
unnnel,
which have the netns leak.


 From d101450583c3a472a2a94904cfe13fd4e7d2f519 Mon Sep 17 00:00:00 2001
=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 29 Jan 2014 16:40:30 +0100
Subject: [PATCH] sit: fix double free of fb_tunnel_dev on exit

This problem was fixed upstream by commit 9434266f2c64 ("sit: fix use a=
fter free
of fb_tunnel_dev").
The upstream patch depends on upstream commit 5e6700b3bf98 ("sit: add s=
upport of
x-netns"), which was not backported into 3.10 branch.

=46irst, explain the problem: when the sit module is unloaded, sit_clea=
nup() is
called.
rmmod sit
=3D> sit_cleanup()
   =3D> rtnl_link_unregister()
     =3D> __rtnl_kill_links()
       =3D> for_each_netdev(net, dev) {
         if (dev->rtnl_link_ops =3D=3D ops)
         	ops->dellink(dev, &list_kill);
         }
At this point, the FB device is deleted (and all sit tunnels).
   =3D> unregister_pernet_device()
     =3D> unregister_pernet_operations()
       =3D> ops_exit_list()
         =3D> sit_exit_net()
           =3D> sit_destroy_tunnels()
           In this function, no tunnel is found.
           =3D> unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
We delete the FB device a second time here!

Because we cannot simply remove the second deletion (sit_exit_net() mus=
t remove
the FB device when a netns is deleted), we add an rtnl ops which delete=
 all sit
device excepting the FB device and thus we can keep the explicit deleti=
on in
sit_exit_net().

CC: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
  net/ipv6/sit.c | 10 ++++++++++
  1 file changed, 10 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0491264b8bfc..620d326e8fdd 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1507,6 +1507,15 @@ static const struct nla_policy=20
ipip6_policy[IFLA_IPTUN_MAX + 1] =3D {
  #endif
  };

+static void ipip6_dellink(struct net_device *dev, struct list_head *he=
ad)
+{
+	struct net *net =3D dev_net(dev);
+	struct sit_net *sitn =3D net_generic(net, sit_net_id);
+
+	if (dev !=3D sitn->fb_tunnel_dev)
+		unregister_netdevice_queue(dev, head);
+}
+
  static struct rtnl_link_ops sit_link_ops __read_mostly =3D {
  	.kind		=3D "sit",
  	.maxtype	=3D IFLA_IPTUN_MAX,
@@ -1517,6 +1526,7 @@ static struct rtnl_link_ops sit_link_ops __read_m=
ostly =3D {
  	.changelink	=3D ipip6_changelink,
  	.get_size	=3D ipip6_get_size,
  	.fill_info	=3D ipip6_fill_info,
+	.dellink	=3D ipip6_dellink,
  };

  static struct xfrm_tunnel sit_handler __read_mostly =3D {
--=20
1.8.4.1
