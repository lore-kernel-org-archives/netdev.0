From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 6/7] add ioctls for adding/removing target
Date: Tue, 19 Jun 2007 20:39:52 +0530
Message-ID: <a781481a0706190809n3387caefv86d289cfd959f805@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC76A.6050006@bx.jp.nec.com>
	 <a781481a0706131341k17170514q7a9d0ce052dbfe2a@mail.gmail.com>
	 <4677AA3D.7010604@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:11442 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644AbXFSPJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 11:09:55 -0400
Received: by ik-out-1112.google.com with SMTP id b32so1605055ika
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 08:09:53 -0700 (PDT)
In-Reply-To: <4677AA3D.7010604@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again Keiichi,

On 6/19/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> Hello Satyam,
>
> > *ugh*. I was wondering what a show-stopper this particular patch
> > was -- introduces a couple of ioctl()'s, exports a new structure to
> > userspace, adds a hitherto-unneeded header file, brings in
> > tty_struct/tty_operations and ends up adding so much complexity/
> > bloat to netconsole.c. Not only that, it must live together (and
> > side-by-side) with the sysfs interface also, because the two of them
> > do different things: sysfs to be able to modify target parameters at
> > run-time and the ioctl()'s to dynamically add/remove targets. We
> > can't really mkdir(2) or rmdir(2) in sysfs so the ioctl()'s are needed.
> >
> > So may I suggest:
> >
> > Just lose *both* the sysfs and ioctl() interfaces and use _configfs_.
> > It is *precisely* the thing you need in your driver here -- the ability
> > to create / destroy kernel objects (or config_items in configfs lingo)
> > from _userspace_ via simple mkdir(2) and rmdir(2). And configfs
> > makes changing multiple configurable parameters atomically trivial
> > too, via rename(2) ... not to mention a sysfs+ioctls -> configfs
> > conversion would help your patchset lose some weight too :-)
>
> Stephen Hemminger previously advised me about the user interface such as
> the following messages.
>
> > Some other speculations:
> > 1. Would it be possible to add ioctl's to /dev/console? This would be more in
> >     keeping with older Unix style model.
> >
> > 2. Using sysfs makes sense if there is a device object that exists to
> >    add the sysfs attributes to.
> >
> > 3. Procfs is handy for summary type tables.
> >
> > 4. Netlink does feel like overkill for this. Although newer generic netlink
> >    makes it easier.
>
> So, I implemented ioctls to add/remove port like this patch on the tty driver.
> But I'm going to search configfs. Thank you for you information.

Hmm, I might've missed this thread, but my opinion on the
alternatives, fwiw:

1. I think adding new ioctl's to the kernel are generally disliked for
obvious reasons. Perhaps Stephen meant to add some generic
ioctl's above (and not separate ones specially implemented for
the dynamically reconfigurable netconsole driver)?

2. sysfs: In fact after reading Stephen's comment above I now noticed/
realized that we're introducing the misc device thing _specifically_ to
be able to attach kobjects for our use in the /sys/class/misc/
namespace? IMHO all such stuff (and the stuff we're adding to be able
to export the ioctl interface) would become unnecessary / redundant if
we switch to configfs, thus making this patchset quite small.

3. Again, as Stephen mentions, procfs interfaces are generally used
for different cases ... personally, I wouldn't even consider a procfs
interface for our case here :-)

4. Yup, netlink is clearly overkill. Also, I think that would require a
special application on the userspace side to talk over the netlink
socket, so we lose the ability to "echo > " from shell ... again,
netlink isn't _quite_ the thing for our case here, IMHO.

Please do consider configfs. Note that we'll have to lose the sysfs
symlink from your target's kobject to the kobject of the ethernet
device if we switch to configfs, but was that symlink needed for
some essential functionality or was it simply for informational
purpose? IMHO, this patchset only needs to bring in functionality
to be able to create, destroy, and modify netconsole targets at
run-time, and all these reconfiguration tasks would be handled
quite well by configfs, AFAICT.

Thanks again,
Satyam

PS: I really liked this patchset (and the idea behind it), and was
thinking of doing a configfs conversion myself, if you hadn't
replied :-) configfs has similar interfaces / structures as sysfs,
so it shouldn't really be too time-consuming.
