From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Thu, 11 Aug 2016 14:17:00 -0600
Message-ID: <20160811141700.4f4faabb@t450s.home>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	<1452684335-46107-4-git-send-email-hare@suse.de>
	<20160209210458.GB32530@localhost>
	<bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	<CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
	<1470787409.3015.81.camel@kernel.crashing.org>
	<CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
	<1470873296.3015.117.camel@kernel.crashing.org>
	<CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>, santosh@chelsio.com,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UcPh2RZazDL-cJbJkZFUJ03kTocn5H7WA=Kk_+S-CV_HA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Aug 2016 11:52:02 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Wed, Aug 10, 2016 at 4:54 PM, Benjamin Herrenschmidt
> <benh@kernel.crashing.org> wrote:
> > On Wed, 2016-08-10 at 08:47 -0700, Alexander Duyck wrote:  
> >>
> >> The problem is if we don't do this it becomes possible for a guest to
> >> essentially cripple a device on the host by just accessing VPD
> >> regions that aren't actually viable on many devices.  
> >
> > And ? We already can cripple the device in so many different ways
> > simpy because we have pretty much full BAR access to it...
> >  
> >>  We are much better off
> >> in terms of security and stability if we restrict access to what
> >> should be accessible.  
> >
> > Bollox. I've heard that argument over and over again, it never stood
> > and still doesn't.
> >
> > We have full BAR access for god sake. We can already destroy the device
> > in many cases (think: reflashing microcode, internal debug bus access
> > with a route to the config space, voltage/freq control ....).
> >
> > We aren't protecting anything more here, we are just adding layers of
> > bloat, complication and bugs.  
> 
> To some extent I can agree with you.  I don't know if we should be
> restricting the VFIO based interface the same way we restrict systemd
> from accessing this region.  In the case of VFIO maybe we need to look
> at a different approach for accessing this.  Perhaps we need a
> privileged version of the VPD accessors that could be used by things
> like VFIO and the cxgb3 driver since they are assumed to be a bit
> smarter than those interfaces that were just trying to slurp up
> something like 4K of VPD data.
> 
> >>  In this case what has happened is that the
> >> vendor threw in an extra out-of-spec block and just expected it to
> >> work.  
> >
> > Like vendors do all the time in all sort of places
> >
> > I still completely fail to see the point in acting as a filtering
> > middle man.  
> 
> The problem is we are having to do some filtering because things like
> systemd were using dumb accessors that were trying to suck down 4K of
> VPD data instead of trying to parse through and read it a field at a
> time.

vfio isn't playing nanny here for the fun of it, part of the reason we
have vpd access functions is because folks have discovered that vpd
registers between PCI functions on multi-function devices may be
shared.  So pounding on vpd registers for function 1 may adversely
affect someone else reading from a different function.  This is a case
where I feel vfio needs to step in because if that's a user competing
with the host or two users stepping on each other, well that's exactly
what vfio tries to prevent.  A driver in userspace or a VM driver can't
very well determine these sorts of interactions when it only has
visibility to a subset of the functions and users and hardware folks
would throw a fit if I extended iommu groups to encompass all the
related devices rather than take the relatively simple step of
virtualizing these accesses and occasionally quirking devices that are
extra broken, as seems to be required here.  Thanks,

Alex
