From: Laszlo Ersek <lersek@redhat.com>
Subject: lost gARP after live migration
Date: Tue, 28 Jun 2011 15:01:20 +0200
Message-ID: <4E09D0A0.1080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>
To: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Hi,

with reference to RHBZ#713585:

It seems when a RHEL-6.1 or F-15 Xen PV guest is live migrated, the 
gratuitous ARP packet is not forwarded to the affected "networking 
equipment". The netback vif is added to a routed bridge in the host(s) 
and external hosts are expeted to have connection to the guest at all 
times, no matter the current Xen host.

I experimented a bit with tcpdump, and the gARP does appear on the 
netfront interface. It also appears on the host bridge if sufficient 
time passes between completing the xenbus handshake and sending the gARP.

When the guest queues eg. three gARPs in rapid succession, a variable 
number of them gets lost. (When all such packets disappear, then the 
migrated guest becomes invisible to the outside world, until it 
initiates network traffic on its own.)

When the guest waits for about half a second before sending (queueing), 
the very first gARP packet successfully appears on the host bridge.

I suspect it's a timing race against the netback vif being added to the 
host bridge. What would be a good countermeasure?

- Adding two modparams to xen-netfront (gARP requeue count & number of 
msecs to wait between queueing the gARPs).
- (Paolo's idea:) watching the "hotplug-status" xenstore node and 
sending a single gARP when the watch fires with "connected". This node 
belongs to the backend xenstore subtree, thus watching it from the guest 
doesn't please the architecture astronaut in me.
- Something else.

Sorry for the naivety / verbiage.

Thanks,
lacos
