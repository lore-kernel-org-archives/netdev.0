From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Powerpc / eHEA] Circular dependency with 2.6.29-rc6
Date: Wed, 25 Feb 2009 16:50:13 +0100
Message-ID: <1235577013.4645.3548.camel@laptop>
References: <49A26290.60607@in.ibm.com>  <49A55E54.4080304@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: TKLEIN@de.ibm.com, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Mel Gorman <mel@csn.ul.ie>, netdev <netdev@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@elte.hu>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49A55E54.4080304@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-02-25 at 16:05 +0100, Jan-Bernd Themann wrote:

> - When "open" is called for a registered network device, port->port_lock
> is taken first,
>   then ehea_fw_handles.lock
> - When "open" is left these locks are released in a proper way (inverse
> order)

So this has:

  port->port_lock
    ehea_fw_handles.lock

This would be the case that is generating the warning.

> - In addition: ehea_fw_handles.lock is held by the function
> "driver_probe_device"
>   that registers all available network devices (register_netdev)
> - When multiple network devices are registered, it is possible that
> "open" is
>   called on an already registered network device while further
> netdevices are still registered
>   in "driver_probe_device". ---> "open" will take port->port_lock, but
> won't get ehea_fw_handles.lock

Right, so here you have 

  ehea_fw_handles.lock
    port->port_lock

Overlay these two cases and you have AB-BA deadlocks.

> - However, ehea_fw_handles.lock is freed once all netdevices are registered.
> - When the second netdevice is registered in "driver_probe_device", it
> will also try to get
>   the port->port_lock (which in fact is a different one, as there is one
> per netdevice).
> - Does the mutex debug mechanism distinguish between the different
> port->port_lock instances?

Not unless you tell it to.

Are you really sure the port->port_lock in this AB-BA scenario are never
the same? The above explanation didn't convince me (also very hard to
read due to funny wrapping).

Suppose you do an open concurrently with a re-probe, which apparently
takes port->port_lock's of existing devices, in the above scenario that
deadlocks.
