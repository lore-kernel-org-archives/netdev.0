From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Sat, 04 Oct 2003 08:50:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310041250.h94Co0kT017402@ginger.cmf.nrl.navy.mil>
References: <20031004065925.GB94203@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: Your message of "Fri, 03 Oct 2003 23:59:25 PDT."
             <20031004065925.GB94203@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

just to summarize the last couple messages and my thoughts about
all of this:

atm_dev will become a netdevice in the future.  there is no good reason
it shouldnt.  the atm layer needs to start doing things the 'netdevice'
way.

ATM_ITF_ANY is rarely used.  we just need it to work properly with
a minimum of effort.  the rtnl semaphore blocks modifications to the
device list so routines that might sleep can safely iterate it.  there are
(currently) no atm devices with slow open routines so please dont bother
with hypothetical devices.  people who use ATM_ITF_ANY are going to pay
a penalty.  that's just the way it is.  its a bit of a bad idea really.
what if you want something like round-robin instead of in-order?

should vcc->open() and vcc->close() sleep?  this is a problem for some
people.  i can see why you might want to sleep in close() -- like waiting
for all the skb's to transmit/return, but this is only because vcc's dont
hold a per skb reference count and dont know when its safe to go away (and
this becuase the atm transmit side doesnt skb_clone() like it should).

serialization for open/change_qos/close should be handled in the
driver (assuming we are discussing serialization across different
vcc's and not a single vcc -- a single vcc case is already
handled via lock_sock).  if your driver h/w doesnt need this, then 
it shouldnt be thrust upon you.  further, i believe this is wrong
thinking.  what data are you protecting with this lock?  (the he
driver has a 'global' lock, but its used to protect the register
space, which has a serialization effect).

vcc_sklist holds a list of sockets active or otherwise.  the atm layer
already has flags (ATM_VF_READY) that indicate if a vcc is ready to recv.
it is unfortunate that the bh's of most drivers dont bother to check this
bit (assuming some other mechanism isnt used to prevent the bottom half
from running while opening/preparing a vcc).  in the future (and this
isnt a hypothetical driver) vcc's will probably live slightly longer than
the close routine (those outstanding skbs) and cant be removed from the
vcc_sklist until every last reference is gone.  yes, this means that close
could finish but you wouldnt be able to open the vpi/vci again right away.
