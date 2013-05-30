From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH v2 1/2] net: introduce MAC_TABLE_CHANGED
 event
Date: Thu, 30 May 2013 21:50:35 +0800
Message-ID: <20130530135035.GB3860@t430s.nay.redhat.com>
References: <20130523115403.4d5f587a@redhat.com>
	<20130523171834.GA31349@redhat.com>
	<20130523132633.388ee1c5@redhat.com>
	<20130524121016.GC8669@redhat.com>
	<20130524085136.4e13ab49@redhat.com>
	<20130527093425.GC6120@t430s.nay.redhat.com>
	<20130527091011.1a8bf205@redhat.com>
	<20130527092428.0ce3581d@redhat.com>
	<20130527224304.GA1822@t430s.nay.redhat.com>
	<20130528082556.2deb1095@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	stefanha@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>
To: Luiz Capitulino <lcapitulino@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20130528082556.2deb1095@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Tue, May 28, 2013 at 08:25:56AM -0400, Luiz Capitulino wrote:
> On Tue, 28 May 2013 06:43:04 +0800
> Amos Kong <akong@redhat.com> wrote:

CC: netdev, vlad

Currently we create & open macvtap device by libvirt(management),
and pass the fd to qemu process. And macvtap works in promiscuous
mode, we want to sync the rx-filter setup of virtio-net to macvtap
device for better performance.

qemu might be a non-privileged process, it doesn't have permission
to setup macvtap device. So we want to add an QMP event to notify
management to execute the setup.

mac-programming over macvtap patch for qemu:
http://lists.nongnu.org/archive/html/qemu-devel/2013-05/msg03337.html


Can we re-consider to setup macvtap in qemu directly? open some setup
permission of rx-filter to qemu process? will do some investigation.
 

> > On Mon, May 27, 2013 at 09:24:28AM -0400, Luiz Capitulino wrote:
> > > On Mon, 27 May 2013 09:10:11 -0400
> > > Luiz Capitulino <lcapitulino@redhat.com> wrote:
> > > 
> > > > > We use the QMP event to notify management about the mac changing.
> > > > > 
> > > > > In this thread, we _wrongly_ considered to use qmp approach to delay
> > > > > the event for avoiding the flooding.
> > > > > 
> > > > >   eg: monitor_protocol_event_throttle(NIC_RX_FILTER_CHANGED, 1000);
> > > > > 
> > > > > Now we have a solution (using a flag to turn on/off the notify) to avoid the
> > > > > flooding, only emit the event if we have no un-read event.
> > > > > 
> > > > > If we want to (flag is on) emit the event, we wish the event be sent ASAP
> > > > > (so event_throttle isn't needed).
> > > > 
> > > > Unfortunately this doesn't answer my question. I did understand why you're
> > > > not using the event throttle API (which is because you don't want to slow down
> > > > the guest, not the QMP client).
> > > > 
> > > > My point is whether coupling the event with the query command is really
> > > > justified or even if it really fixes the problem. Two points:
> > > > 
> > > >  1. Coupling them is bad design, and will probably strike back, as we plan
> > > >     for a better API for events where events can be disabled
> > > 
> > > I meant we may in the future, for example, introduce the ability to disable
> > > commands (and events). One could argue that the event w/o a query command
> > > is not that useful, as events can be lost. But loosing an event is one thing,
> > > not having it because it got disabled by a side effect is another.
> > 
> > event_throttle() couples the event in QMP framework, but we use flags
> > to disabled the event from real source (emit points/senders). 
> > 
> > If we set the evstate->rate to -1, we can ignore the events in
> > monitor_protocol_event_queue(), but we could not control the event
> > emitting of each emit point (each nic).
> >  
> > > But anyway, my main point in this thread is to make sure we at least
> > > justify having this coupling. Aren't we optimizing prematurely? Aren't
> > > we optimizing for a corner case? That's what I want to see answered.
> > 
> > If it's a corner case, we don't need a general API to disable event.
> 
> If it's a corner case, it's really worth to fix it?
> 
> I think that what we need a real world test-case to show us we're
> doing the right thing.
> 
> > We can disable this event by a flag, and introduce a new API
> > if we have same request from other events.
> > 
> > > >  2. Can you actually show the problem does exist so that we ensure this is
> > > >     not premature optimization? Might be a good idea to have this in the
> > > >     commit log
> > > > 
> > > > > > (which is to couple the event with the query command) is
> > > > > > appropriate. We're in user-space already, many things could slow
> > > > > > the guest down apart from the event generation.
> > > > > > 
> > > > > > Two questions:
> > > > > > 
> > > > > >  1. Do we know how slow (or how many packets are actually dropped)
> > > > > >     if the mac is changed too often *and* the event is always sent?
> > > > > 
> > > > > We always disable interface first, then change the macaddr.
> > > > > But we just have patch to allow guest to change macaddr of
> > > > > virtio-net when the interface is running.
> > > > > 
> > > > > | commit 2dcd0cce551983afe2f900125457f10bb5d980ae
> > > > > | Author: Jiri Pirko <jpirko@redhat.com>
> > > > > | Date:   Tue Dec 11 15:33:56 2012 -0500
> > > > > | 
> > > > > |     [virt] virtio_net: allow to change mac when iface is running
> > > > > 
> > > > > >  2. Does this solution consider what happens if the QMP client does
> > > > > >     respond timely to the event by issuing the query-rx-filter
> > > > > >     command?
> > > > > 
> > > > > We assume that the QMP client (management) cares about the mac changing
> > > > > event, and will query the latest rx-filter state and sync to macvtap
> > > > > device.
> > > > > 
> > > > > 1) If QMP client respond timely to the event: that's what we expected :)
> > > > 
> > > > Won't this slow down the guest? If not, why?
> > 
> > If guest changes fx-filter configs frequently & management always query the
> > event very timely, this will slow down the guest.
> > 
> > We should detect & process the abnormal behavior from management.
> 
> That's not abnormal. Management is doing what it should do.
> 
> Maybe using the event throttle API can solve the mngt side of the problem,
> but I still think we need a reproducible test-case to ensure we're doing
> the right thing.


The event is triggered by guest, it will change setup of host device.
and we expect the event to be processed ASAP, event delay / lose might
caused unknown problem.

If management fails to setup rx-filter of macvtap device, the error
should be processed:

  1) when qemu changes rx-filter, send event to management, wait until
     management finishs the setup of macvtap device, then return the
     result to guest kernel. the delay is unacceptabled.

  2) qemu changes rx-filter and return to guest kernel, when
     management finishs the setup to macvtap, then tell the result to
     qemu, qemu tells result to guest kernel.
     what's should guest do if setup macvtap doesn't success?

  3) guest changes rx-filter very frequently, management has to query
     it to sync the rx-filter to macvtap.
     I mentioned a solution for management to avoid the security
     issue. but we could not assume management always be believable.


> > Management (qmp client) always respond timely to the event in the
> > begining. If guest changes rx-filter very frequently & continuous.
> > Then we increase the evstate->rate, even disable the event.
> > 
> > In the normal usecase, we should consider packet losing first (caused by
> > event delay + the delay is used by management to execute the change)
> > 
> > ---
> > btw, currently we could not test in real environment. If related
> > libvirt work finishes, we can evaluate with real delays, packet
> > losing, etc.
> > 
> > The worst condition is we could not accept the delay(packet losing),
> > we need to consider other solution for mac programming of macvtap.
> > 
> > > > > 2) If QMP client doesn't respond timely to the event: packets might drop.
> > > > >    If we change mac when the interface is running, we can accept trivial
> > > > >    packets dropping.
> > > > > 
> > > > > For second condition, we need to test in real environment when libvirt
> > > > > finishs the work of processing events.

-- 
			Amos.
