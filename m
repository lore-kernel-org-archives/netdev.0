From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V4 7/7] Drivers: hv: vmbus: disable local interrupt when
 hvsock's callback is running
Date: Fri, 7 Aug 2015 10:24:44 +0000
Message-ID: <0929270e654b4142a5aa399fa7ba50b3@SIXPR30MB031.064d.mgd.msft.net>
References: <1438086930-19483-1-git-send-email-decui@microsoft.com>
 <20150729.152809.1531386671239230150.davem@davemloft.net>
 <77fb17eab5474ee7bf34bb1c148b84ea@SIXPR30MB031.064d.mgd.msft.net>
 <1e6203fcf0c645c98944f25425db9406@SIXPR30MB031.064d.mgd.msft.net>
 <SN1PR0301MB166238F1B5F585B79F6C5F94A0740@SN1PR0301MB1662.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: KY Srinivasan <kys@microsoft.com>, David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <SN1PR0301MB166238F1B5F585B79F6C5F94A0740@SN1PR0301MB1662.namprd03.prod.outlook.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: KY Srinivasan
> Sent: Friday, August 7, 2015 1:50
> To: Dexuan Cui <decui@microsoft.com>; David Miller <davem@davemloft.net>
> Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> stephen@networkplumber.org; stefanha@redhat.com; netdev@vger.kernel.org;
> apw@canonical.com; pebolle@tiscali.nl; dan.carpenter@oracle.com
> Subject: RE: [PATCH V4 7/7] Drivers: hv: vmbus: disable local interrupt when
> hvsock's callback is running
> > From: Dexuan Cui
> > Sent: Wednesday, August 5, 2015 9:44 PM
> > To: David Miller <davem@davemloft.net>; KY Srinivasan
> > <kys@microsoft.com>
> > Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> > driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> > stephen@networkplumber.org; stefanha@redhat.com;
> > netdev@vger.kernel.org; apw@canonical.com; pebolle@tiscali.nl;
> > dan.carpenter@oracle.com
> > Subject: RE: [PATCH V4 7/7] Drivers: hv: vmbus: disable local interrupt when
> > hvsock's callback is running
> >
> > > From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> > Behalf
> > > Of Dexuan Cui
> > > Sent: Thursday, July 30, 2015 18:18
> > > To: David Miller <davem@davemloft.net>; KY Srinivasan
> > <kys@microsoft.com>
> > > Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> > > driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> > > stephen@networkplumber.org; stefanha@redhat.com;
> > netdev@vger.kernel.org;
> > > apw@canonical.com; pebolle@tiscali.nl; dan.carpenter@oracle.com
> > > Subject: RE: [PATCH V4 7/7] Drivers: hv: vmbus: disable local interrupt
> > when
> > > hvsock's callback is running
> > >
> > > > From: David Miller
> > > > Sent: Thursday, July 30, 2015 6:28
> > > > > From: Dexuan Cui <decui@microsoft.com>
> > > > > Date: Tue, 28 Jul 2015 05:35:30 -0700
> > > > >
> > > > > In the SMP guest case, when the per-channel callback hvsock_events()
> > is
> > > > > running on virtual CPU A, if the guest tries to close the connection on
> > > > > virtual CPU B: we invoke vmbus_close() -> vmbus_close_internal(),
> > > > > then we can have trouble: on B, vmbus_close_internal() will send IPI
> > > > > reset_channel_cb() to A, trying to set channel->onchannel_callbackto
> > NULL;
> > > > > on A, if the IPI handler happens between
> > > > > "if (channel->onchannel_callback != NULL)" and invoking
> > > > > channel->onchannel_callback, we'll invoke a function pointer of NULL.
> > > > >
> > > > > This is why the patch is necessary.
> > > > >
> > > > Sorry, I do not accept that you must use conditional locking and/or
> > > > IRQ disabling.
> > > >
> > > > Boil it down to what is necessary for the least common denominator,
> > > > and use that unconditionally.
> > >
> > > Hi David,
> > > Thanks for the comment!
> > >
> > > I agree with you it's not clean to use conditional IRQ disabling.
> > >
> > > Here I didn't use unconditionally IRQ disabling because the Hyper-V netvsc
> > > and storvsc driver's vmbus event callbacks (i.e. netvsc_channel_cb() and
> > > storvsc_on_channel_callback()) may take relatively long time (e.g., netvsc
> > can
> > > operate at a speed of 10Gb) and I think it's bad to disable IRQ for long time
> > > when the callbacks are running in a tasklet context, e.g., the Hyper-V timer
> > > can be affected: see vmbus_isr() -> hv_process_timer_expiration().
> > >
> > > To resolve the race condition between vmbus_close_internal() and
> > > process_chn_event() in SMP case, now I propose a new method:
> > >
> > > we can serialize the 2 paths by adding
> > > tasklet_disable(hv_context.event_dpc[channel->target_cpu]) and
> > > tasklet_enable(...) in vmbus_close_internal().
> > >
> > > In this way, we need the least change and we can drop this patch.
> > >
> > > Please let me know your opinion.
> > >
> > > -- Dexuan
> >
> > Hi David, KY and all,
> >
> > May I know your opinion about my idea of adding tasklet_disable/enbable()
> > in vmbus_close_internal() and dropping this patch?
> 
> Sorry for the delayed response; I think this is a reasonable solution. Send me the
> patch.
> 
> Regards,
> 
> K. Y

OK. Will do.

 Thanks,
 -- Dexuan
