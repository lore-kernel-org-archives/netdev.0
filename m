From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: lost gARP after live migration
Date: Tue, 28 Jun 2011 14:33:39 +0100
Message-ID: <1309268019.32717.322.camel@zakaz.uk.xensource.com>
References: <4E09D0A0.1080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Paolo Bonzini <pbonzini@redhat.com>
To: Laszlo Ersek <lersek@redhat.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4E09D0A0.1080107@redhat.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-28 at 14:01 +0100, Laszlo Ersek wrote:
> Hi,
> 
> with reference to RHBZ#713585:
> 
> It seems when a RHEL-6.1 or F-15 Xen PV guest is live migrated, the 
> gratuitous ARP packet is not forwarded to the affected "networking 
> equipment". The netback vif is added to a routed bridge in the host(s) 
> and external hosts are expeted to have connection to the guest at all 
> times, no matter the current Xen host.
> 
> I experimented a bit with tcpdump, and the gARP does appear on the 
> netfront interface. It also appears on the host bridge if sufficient 
> time passes between completing the xenbus handshake and sending the gARP.
> 
> When the guest queues eg. three gARPs in rapid succession, a variable 
> number of them gets lost. (When all such packets disappear, then the 
> migrated guest becomes invisible to the outside world, until it 
> initiates network traffic on its own.)
> 
> When the guest waits for about half a second before sending (queueing), 
> the very first gARP packet successfully appears on the host bridge.
> 
> I suspect it's a timing race against the netback vif being added to the 
> host bridge. What would be a good countermeasure?
> 
> - Adding two modparams to xen-netfront (gARP requeue count & number of 
> msecs to wait between queueing the gARPs).
> - (Paolo's idea:) watching the "hotplug-status" xenstore node and 
> sending a single gARP when the watch fires with "connected". This node 
> belongs to the backend xenstore subtree, thus watching it from the guest 
> doesn't please the architecture astronaut in me.

netback already waits (or should...) for hotplug-status to fire with
"connected" before moving to state XenbusStateConnected. See
hotplug_status_changed in drivers/net/xen-netback/xenbus.c. You need
either the netback in upstream or something newer than 43223efd9bfd (C
Feb 2010) if you are using e.g. xen.git#xen/next-2.6.32. That commit
fixes pretty much the issue you describe.

I expected that netfront waited for the backend to hit
XenbusStateConnected before sending the grat ARP but instead I find it
happens when the backend hits XenbusStateInitWait. I'm not sure if that
is a problem -- it appears to have been done this way since forever
(even back in the classic Xen kernels) and I've never noticed a gARP go
missing in the way you describe, but perhaps something isn't quite
matching up any more.

Ian.

> - Something else.
> 
> Sorry for the naivety / verbiage.
> 
> Thanks,
> lacos
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xensource.com
> http://lists.xensource.com/xen-devel
