From: spereira <pereira.shaun@gmail.com>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels- Question regarding...
Date: Tue, 11 Oct 2005 17:09:07 +1000
Message-ID: <3ad486780510110009s2de65e68vf19e283edf997e89@mail.gmail.com>
References: <3ad486780510092121h78a522cat11f33581dfc670dc@mail.gmail.com>
	 <200510101348.49598.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751398AbVJKHJK@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200510101348.49598.arnd@arndb.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Arnd
If I have understood correctly the following would be the changes I
would have to make in the kernel...Please correct me if I am wrong.

It seems to me step (d) would be as you say a little tricky but I
could attempt it
depending on the amount of time I have in the project I am on at the moment.
Proposed modifications...
a) Struct file_operations(include/linux/fs.h) has a compat_ioctl hook for file
ioctls. Include a compat_proto_ioctl hook in proto_ops(include/net.h) for
modular socket ioctls.

b) socket.c has a 'file_operations' type struct socket_file_ops where the
.compat_ioctl member is currently not used. Define compat_sock_ioctl in
socket.c and assign to .compat_ioctl member of socket_file_ops
This is ifdef'd with CONFIG_COMPAT

c) compat_sock_ioctl will by default call the protocol's ioctl
 currently supporting the socket interface when handling modular socket ioctls,
like so. socket->ops->compat_proto_ioctl(...)
which in this case is x25_compat_ioctl.

d)If compat_sock_ioctl has to perform a function similar to
sock_ioctl(socket.c)
where in SIOC* commands are handled, then introduce a newly defined
compat_dev_ioctl that would have stuff like dev_ifsioc that would have
previously
been removed from fs/compat_ioctl.c.
Then the protocol's ioctl (called by default in the step c above) would itself
default to compat_dev_ioctl ensuring other socket layer
ioctls are handled by the device layer function, compat_dev_ioctl

regards,
Shaun


On 10/10/05, Arnd Bergmann <arnd@arndb.de> wrote:
> On Maandag 10 Oktober 2005 06:21, spereira wrote:
> >
> > Is there currently an alternative to register_ioctl32_conversion that
> > would help achive 32 bit ioctl emulation at the socket layer?
> > Any suggestions/advice whould be much appreciated.
>
> The correct solution would be to add the missing functionality to
> net/socket.c and move over the implementation of SIOC* from
> fs/compat_ioctl.c. Getting the code path right is a little tricky,
> but I think a patch to fix this up would be appreciated.
>
> As a start, you could define a compat_sock_ioctl along the
> lines of compat_blkdev_ioctl and add your own handlers to the
> x25_proto_ops, but IMHO it would makes sense to get rid of stuff
> like dev_ifsioc from fs/compat_ioctl.c at the same time by
> introducing a new compat_dev_ioctl called from compat_sock_ioctl.
>
>         Arnd <><
>
