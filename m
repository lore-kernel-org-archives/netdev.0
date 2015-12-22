From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Tue, 22 Dec 2015 12:01:22 +0100
Message-ID: <1450782082.8824.23.camel@suse.com>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Wu <peter@lekensteyn.nl>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Lu Baolu <baolu.lu@linux.intel.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-22 at 09:48 +0000, Hayes Wang wrote:
>  Peter Wu [mailto:peter@lekensteyn.nl]
> > Sent: Tuesday, December 08, 2015 10:33 PM
> [...]
> > I found another problem with runtime PM. When a device is suspended via
> > autosuspend and a system suspend takes place, there is no network I/O
> > after resume. Triggering a renegotiation (ethtool -r eth1) brings back
> > network activity.
> 
> I think it is relative to the firmware. Could you try the driver from Realtek website?

Hi,

at the risk of repeating myself I must say that there is a logic flaw
in the driver. If you look at this code:

static int rtl8152_resume(struct usb_interface *intf)
{
        struct r8152 *tp = usb_get_intfdata(intf);

        mutex_lock(&tp->control);

        if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
                tp->rtl_ops.init(tp);
                netif_device_attach(tp->netdev);
        }

        if (netif_running(tp->netdev) && tp->netdev->flags & IFF_UP) {
                if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
                        rtl_runtime_suspend_enable(tp, false);
                        clear_bit(SELECTIVE_SUSPEND, &tp->flags);
                        napi_disable(&tp->napi);
                        set_bit(WORK_ENABLE, &tp->flags);
                        if (netif_carrier_ok(tp->netdev))
                                rtl_start_rx(tp);
                        napi_enable(&tp->napi);
                } else {
                        tp->rtl_ops.up(tp);
                        rtl8152_set_speed(tp, AUTONEG_ENABLE,
                                          tp->mii.supports_gmii ?
                                          SPEED_1000 : SPEED_100,
                                          DUPLEX_FULL);
                        netif_carrier_off(tp->netdev);
                        set_bit(WORK_ENABLE, &tp->flags);
                }

You need to understand that its use of the flag SELECTIVE_SUSPEND
is invalid. SELECTIVE_SUSPEND is used at two places in the driver.

Once in rtl8152_start_xmit(), where it is working but misnamed.
At that time you need to know whether the device is suspended.
To the device it does not matter whether the suspension is selective
or for the whole bus. It cannot tell. The driver just needs to know
whether it should resume the device if a packet to be transmitted
through it is given to the driver. So far all is well.

But at the time rtl8152_resume() is called the flag has become
meaningless. It tells you whether the device was selectively suspended
(we call that autosuspended, but the concept is the same), but you
take it to mean that it was _only_ selectively suspended. It does not
tell you that.
That matters a lot because the behavior of the host regarding powering
the bus during S3 and S4 is not defined. As I mentioned the device
can't tell whether it is selectively suspended. But it does notice
if its power supply is cut. In that case the driver must reinitialize
the device.
The current code does that conditional on
!test_bit(SELECTIVE_SUSPEND ... )
That is wrong because you need to do this if power was lost. The test
only tells you whether the device was selectively suspend before
power was lost (if power was lost). That is not the same thing at all.

The way the USB subsystem is designed is that it tells you whether power
had been cut by calling reset_resume() if power was cut or resume() if
power was kept.
If reset_resume() is called you must always execute this code:

                tp->rtl_ops.init(tp);

and

                        tp->rtl_ops.up(tp);
                        rtl8152_set_speed(tp, AUTONEG_ENABLE,
                                          tp->mii.supports_gmii ?
                                          SPEED_1000 : SPEED_100,
                                          DUPLEX_FULL);

The conditions used in rtl8152_resume() are wrong.
That is the reason "ethtool -r eth1" is reported to restore the device.
It triggers equivalent operations.

It is clear to me that you cannot get away with using the same operation
for resume() and reset_resume() in your driver. It is fundamentally
impossible. Firmware cannot fix it.

Sorry for the length of the explanation.

	HTH
		Oliver
