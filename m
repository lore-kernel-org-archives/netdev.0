From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Tue, 16 Aug 2016 10:13:11 +1000
Message-ID: <1471306391.12231.137.camel@kernel.crashing.org>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	 <1452684335-46107-4-git-send-email-hare@suse.de>
	 <20160209210458.GB32530@localhost>
	 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
	 <1470787409.3015.81.camel@kernel.crashing.org>
	 <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
	 <1470873296.3015.117.camel@kernel.crashing.org>
	 <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
	 <20160811141700.4f4faabb@t450s.home>
	 <1470978669.3015.155.camel@kernel.crashing.org>
	 <197F6532-FC5E-4D72-976D-4207BAD8D83E@intel.com>
	 <1471299799.12231.121.camel@kernel.crashing.org>
	 <1471300400.12231.130.camel@kernel.crashing.org>
	 <B64D748A-711E-4701-96EF-C447333F5BF5@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	"santosh@chelsio.com" <santosh@chelsio.com>,
	Netdev <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B64D748A-711E-4701-96EF-C447333F5BF5@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-08-15 at 23:16 +0000, Rustad, Mark D wrote:
> 
> Bugs in existing guests is an interesting case, but I have been focused on  
> getting acceptable behavior from a properly functioning guest, in the face  
> of hardware issues that can only be resolved in a single place.
> 
> I agree that a malicious guest can cause all kinds of havoc with  
> directly-assigned devices. Consider a 4-port PHY chip on a shared MDIO bus,  
> for instance. There is really nothing to be done about the potential for  
> mischief with that kind of thing.
> 
> The VPD problem that I had been concerned about arises from a bad design in  
> the PCI spec together with implementations that share the registers across  
> functions. The hardware isn't going to change and I really doubt that the  
> spec will either, so we address it the only place we can.

Right but as I mentioned, there are plenty of holes when it comes to
having multi function devices assigned to different guests, this is just
one of them.

Now, that being said, "working around" the bug to make the "non fully secure"
case work (in my example case the "desktop user") is probably an ok workaround
as long as we fully agree that this is all it is, it by no means provide
actual isolation or security.
 
> >   >   rtain that we agree that not everything can or should be addressed  
> in vfio. I did not mean to suggest it should try to address everything, but  
> I think it should make it possible for correctly behaving guests to work. I  
> think that is not unreasonable.

Again as long as there is no expectation of security here, such as a data
center giving PCI access to some devices.

> > Perhaps the VPD range check should really just have been implemented for  
> the sysfs interface, and left the vfio case unchecked. I don't know because  
> I was not involved in that issue. Perhaps someone more intimately involved  
> can comment on that notion.

That would have been my preferred approach... I think VFIO tries to do too much
which complicates things, causes other bugs, without briging actual safety. I
don't think it should stand in between a guest driver and its device unless
absolutely necessary to provide the functionality due to broken HW or design,
but with the full understanding that doing so remains unsafe from an isolation
standpoint.

> > > Assuming that a device coming back from a guest is functional and not
> > completely broken and can be re-used without a full PERST or power cycle
> > is a wrong assumption. It may or may not work, no amount of "filtering"
> > will fix the fundamental issue. If your HW won't give you access to PERST
> > well ... blame Intel for not specifying a standard way to generate it in
> > the first place :-)
> 
> Yeah, I worry about the state that a malicious guest could leave a device  
> in, but I consider direct assignment always risky anyway. I would just like  
> it to at least work in the non-malicious guest cases.

Right. Only SR-IOV which is somewhat designed for assignment is reasonably safe
in the general case.

On server POWER boxes, we have isolation at the bus level with usual per-slot
PERST control so we are in a much better situation but we also for all the
above reasons, only allow a slot granularity for pass-through.

> > I guess my previous response was really just too terse, I was just focused  
> on unavoidable hangs and data corruption, which even were happening without  
> any guest involvement. For me, guests were just an additional exposure of  
> the same underlying issue.
> 
> With hindsight, it is easy to see that a standard reset would now be a  
> pretty useful thing. I am sure that even if it existed, we would now have  
> lots and lots of quirks around it as well! :-)

Hehe yes, well, HW for you ...

Cheers,
Ben.

> > --
> Mark Rustad, Networking Division, Intel Corporation
