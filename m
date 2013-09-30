From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V5 net-next 0/3] The huawei_cdc_ncm driver
Date: Mon, 30 Sep 2013 10:56:23 +0200
Message-ID: <87zjquhemg.fsf@nemi.mork.no>
References: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Liu Junliang <liujunliang_ljl@163.com>,
	linux-kernel@vger.kernel.org (open list),
	linux-usb@vger.kernel.org (open list:USB NETWORKING DR...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	ModemManager-devel@lists.freedesktop.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com> (Enrico
	Mioso's message of "Mon, 30 Sep 2013 04:50:06 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> So this is a new, revised, edition of the huawei_cdc_ncm.c driver, wh=
ich=20
> supports devices resembling the NCM standard, but using it also as a =
mean=20
> to encapsulate other protocols, as is the case for the Huawei E3131 a=
nd
> E3251 modem devices.
> Some precisations are needed however - and I encourage discussion on =
this: and=20
> that's why I'm sending this message with a broader CC.
> Merging those patches might change:
> - the way Modem Manager interacts with those devices
> - some regressions might be possible if there are some unknown firmwa=
re=20
>   variants around (Franko?)
>
> First of all: I observed the behaviours of two devices.
> Huawei E3131: this device doesn't accept NDIS setup requests unless t=
hey're=20
> sent via the embedded AT channel exposed by this driver.
> So actually we gain funcionality in this case!
>
> The second case, is the Huawei E3251: which works with standard NCM d=
river,=20
> still exposing an AT embedded channel. Whith this patch set applied, =
you gain=20
> some funcionality, loosing the ability to catch standard NCM events f=
or now.
> The device will work in both ways with no problems, but this has to b=
e=20
> acknowledged and discussed. Might be we can develop this driver furth=
er to=20
> change this, when more devices are tested.

Your driver, and the cdc-wdm subdriver API in general, could certainly
be extended to support standard NCM events.  There have been some
discussions in the linux-usb list already on how to best do this.  I
believe this message from Oliver is the current conclusion to that
discussion: http://www.spinics.net/lists/linux-usb/msg70140.html

I.e:
 - extend the cdc-wdm subdriver API by creating a struct holding all
   necessary callbacks, and use this struct instead of the current
   single "manage_power" callback, and
 - create one callback hook per notification you want to handle, with
   clear semantics and reasonable names

But I still believe your driver should go in as it is for now. As you
note, it is required for the E3131.  And the same is most likely the
case for other devices in the same family.

Handling the NCM notifications can always be added later. IMHO, they ca=
n
be considered optional given that a separate management channel is
required in any case to configure these devices and start/stop the
connection.  The NCM events you lose compared to cdc_ncm are
NETWORK_CONNECTION and SPEED_CHANGE. The first one is useful as it is
implemented in cdc_ncm because it controls the network device link
state, but it is still redundant for devices like these where a managin=
g
userspace application is required and the connection events are
available via the management channel.  The implementation of
SPEED_CHANGE events is less useful. The cdc_ncm driver doesn't use the
received speed data for anything except printing an informational
message.  I don't think implementing it in your driver will gain you
anything.

> We where thinking Huawei changed their interfaces on new devices - bu=
t probably=20
> this driver only works around a nice firmware bug present in E3131, w=
hich=20
> prevented the modem from being used in NDIS mode.

I am not sure this is a firmware bug.  It could very well be by design,
and the differences in observed behaviour could be just artifacts of th=
e
interface implementation on top of different chipsets and/or base
firmwares.  AFAIK, Huawei have never officially supported the serial
port for network device management on this class of devices. The
embedded AT channel is most likely the only AT command channel intended
for network device management, even on the devices with serial ports.

> I think committing this is definitely wortth-while, since it will all=
ow for=20
> more Huawei devices to be used without serial connection. Some device=
s like the=20
> E3251 also, reports some status information only via the embedded AT =
channel,=20
> at least in my case.
> Note: I'm not subscribed to any list except the Modem Manager's one, =
so please=20
> CC me, thanks!!

Yes, this is most definitely a driver worth being added.  There are a
number of devices which just cannot be made working in Linux without it
because the embedded management channel is the only one available.

I don't know if you are aware of this, but I have pointed a few people
to your previous submission attempts and there are therefore some
success stories around already.  An example:
http://lists.freedesktop.org/archives/libqmi-devel/2013-September/00065=
0.html


Bj=C3=B8rn
