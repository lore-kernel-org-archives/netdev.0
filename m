From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 11:57:04 -0400
Message-ID: <1494950224.3259.98.camel@redhat.com>
References: <20170514055848.GA23149@lst.de>
         <20170514.115116.499149210596634881.davem@davemloft.net>
         <1494788929.21774.1.camel@sandisk.com>
         <20170514.204404.1844909849561204299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org,
        "Torvalds, Linus" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170514.204404.1844909849561204299.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Linus,

I've added you to this thread.  A quick synopsis: Dave sent you the
net/smc driver for 4.11.  Even though it lives in net/smc, it is, for
the most part, a net<->rdma translator and so it is as much an RDMA
driver as anything else.  And upon review, the rdma community does not
believe either the spec/rfc or the driver are the right way to engineer
this particular technology, and the implementation leaves much to be
desired.

On Sun, 2017-05-14 at 20:44 -0400, David Miller wrote:
> From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
> Date: Sun, 14 May 2017 19:08:50 +0000
> 
> > What is your plan to avoid that applications start using and
> > depending on AF_SMC?
> 
> The API is out there already so we are out of luck, and neither
> you nor I nor anyone else can "stop" this from happening.

That's not true at all.  There's nothing that says we can't revert this
now before it goes any further.  It's only been in two kernels, I'm
positive it hasn't landed in any distros yet, and it can go back to
being something people can add on the side.  Futher, the "standard"
this is based on is not a real standard, it's just a publication and
has not been through a standard track.  I wouldn't consider this "out
there already" until there is a standard that has gone through the
standard track.

Regardless though, I'm rather purturbed about this entire thing.  If
you are right that because this got into 4.11, it's now a done deal,
then the fact that this went through 4 review cycles on netdev@ that,
as I understand it, spanned roughly one years time, and not one single
person bothered to note that this was as much an RDMA driver as
anything else, and not one person bothered to note that linux-rdma@ was
not on the Cc: list, and not one person told the submitters that they
needed to include linux-rdma@ on the Cc: list of these submissions, and
you took it without any review comments from any RDMA people in the
course of a year, or an ack from me to show that the RDMA portion of
this had at least been given some sort of review, was a collosal fuckup
of cross tree maintainer cooperation.

The SMC driver makes several mistakes that people tried to avoid with
previous RDMA standards, it only supports one out of the five possible
link layers (iWARP, IB, OPA, RoCEv1, RoCEv2), it uses a highly
discouraged and deprecated technique for memory registration that is
considered horribly insecure (handing the keys to the castle to anyone
who connects to the machine, aka, the entire memory space is registered
with one key and that key is given to remote connections, so they can
read any bit of kernel memory they want as opposed to whatever we tell
them to read), and the design as articuled in the published rfc seems
incomplete for dealing with any of the other link layers, indicating
that this should have probably stayed out until the rfc was discussed
and updated to address the shortcomings obviously present in the
current rfc.  With all of these issues outstanding against it, I hope
you can see why I think the way I do about you taking it without ever
consulting any of the RDMA community.

But that leaves us with the question of what to do moving forward.
 Probably the number one concern is that this protocol chose to create
a new AF as opposed to reusing the IPv4 and IPv6 address families and
adding an option similar to SCTP for enabling the new protocol on a
specific socket.  The concern is that we have means of addressing all
of the link layers the RDMA subsystem supports using IPv4 or IPv6 (sort
of...it's possible to have IB or OPA without IPoIB, which leaves them
without an IPv4 or IPv6 address, in which case the rdmacm can use
native GUIDs to resolve the other side, but that only works for verbs
connections, in the case of TCP connections, we always require IPoIB to
be present, and so IPv4 or IPv6 is always sufficient).  In the end,
switching this protocol to use AF_INET and AF_INET6 and a protocol
option to enable SMC may be what we need to do.  That, of course,
changes the user space API.  So, are we truly locked in at this point?
 I would suggest that, since this is only present in 4.11 and 4.12, and
I'm sure this has not landed in any distros as of yet (except maybe
something like Fedora rawhide), we can submit a patch to both the
current kernel and the 4.11 stable to set this code as
CONFIG_EXPERIMENTAL and mark the API as possibly going to undergo
change.  Then let the RDMA community work with IBM to get this properly
fixed so that this is a reasonable RDMA driver and not something the
community is ready to immediately trash, and only after we've got it
whipped into shape and the RDMA community is satisfied it is a
reasonable driver that can continue to work with future planned RDMA
subsystem updates and across various link layers, we remove the
EXPERIMENTAL marker and freeze the API for user space.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
