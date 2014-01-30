From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Thu, 30 Jan 2014 10:28:43 +0100
Message-ID: <52EA1B4B.5080403@6wind.com>
References: <20140128205756.074448668@goodmis.org>	<52E8E025.2060803@6wind.com>	<20140129075745.4227a2ed@gandalf.local.home>	<52E9267C.90403@6wind.com> <20140129154811.27fbaf13@gandalf.local.home>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>,
	Willem de Bruijn <willemb@google.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140129154811.27fbaf13@gandalf.local.home>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 29/01/2014 21:48, Steven Rostedt a =E9crit :
> On Wed, 29 Jan 2014 17:04:12 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Your patch serie seems to be the good way to go (note that patch 1/2=
 does not
>> compile) but I think the fix is smaller because we don't have x-netn=
s.
>>
>> Here is my proposal, if you agree, I will send the same patch for ip=
6_tunnnel,
>> which have the netns leak.
>>
>
> Hold on. Seems that the kernels that were being tested in QA had more
> code than what I was testing. Clark had backported "sit: fix use afte=
r
> free of fb_tunnel_dev" and that was what was causing the
> unlist_netdevice() to be missed.
>
> When I started working on vanilla 3.10.27 as well, I first did my
> original patch (which just removes the call to
> unregister_netdevice_queue() from sit_exit_net()). I asked to have th=
at
> added to our kernel for testing, and they told me it was already ther=
e
> via Clark's backport. Then I did the full backport as well and looked
> for the leak. I'm now thinking that the full backport is not needed a=
s
> that was what caused the leak.
>
> According to commit 9434266f2c645d4fcf62a03a8e36ad8075e37943 "sit: fi=
x
> use after free of fb_tunnel_dev", it states:
>
>      Bug: The fallback device is created in sit_init_net and assumed =
to
>      be freed in sit_exit_net. First, it is dereferenced in that
>      function, in sit_destroy_tunnels:
>
>              struct net *net =3D dev_net(sitn->fb_tunnel_dev);
>
>      Prior to this, rtnl_unlink_register has removed all devices that
>      match rtnl_link_ops =3D=3D sit_link_ops.
>
>      Commit 205983c43700 added the line
>
>      +       sitn->fb_tunnel_dev->rtnl_link_ops =3D &sit_link_ops;
>
>      which cases the fallback device to match here and be freed befor=
e it
>      is last dereferenced.
>
> Commit 205983c43700 was backported to 3.10, but without commit
> 5e6700b3bf98 "sit: add support of x-netns" which was what added the
>
>    net =3D dev_net(sitn->fb_tunnel_dev);
>
> Which looks to me that the only reason I need to port back commit
> 5e6700b3bf98 is if I add the full backport of 9434266f2c645d4f.
>
> Seems to me that my original patch may be good enough. The one that I
> said this series obsoletes.
>
> Note, I've talked with the people that are doing the testing, and I'm
> having them revert all changes except for that one fix and rerun the
> tests again. I should know the results by tomorrow.
>
> Let me know if "sit: fix use after free of fb_tunnel_dev" still needs
> to be backported due to some other way that the fallback device can b=
e
> dereferenced after being freed.

Steve, I think the patch I sent yesterday is the good fix. At the end, =
it's
a backport of Willem's patch. Note that he also ack that patch.
The first version you sent (which removes
unregister_netdevice_queue(sitn->fb_tunnel_dev, &list)) will introduce =
a
memory leak when the user destroy a netns.
