From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V5 net-next 2/3] net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
Date: Fri, 01 Nov 2013 12:35:45 +0100
Message-ID: <87fvrgwe0e.fsf@nemi.mork.no>
References: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
	<1380516609-31242-3-git-send-email-mrkiko.rs@gmail.com>
	<1380532073.1484.15.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Liu Junliang <liujunliang_ljl@163.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list\:USB NETWORKING DR..." <linux-usb@vger.kernel.org>,
	"open list\:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	ModemManager-devel@lists.freedesktop.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380532073.1484.15.camel@linux-fkkt.site> (Oliver Neukum's
	message of "Mon, 30 Sep 2013 11:07:53 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum@suse.de> writes:
> On Mon, 2013-09-30 at 04:50 +0000, Enrico Mioso wrote:
>
>> +static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, i=
nt on)
>> +{
>> +	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->dat=
a;
>> +	int rv =3D 0;
>> +
>> +	if ((on && atomic_add_return(1, &drvstate->pmcount) =3D=3D 1) ||
>> +			(!on && atomic_dec_and_test(&drvstate->pmcount))) {
>> +		rv =3D usb_autopm_get_interface(usbnet_dev->intf);
>> +		if (rv < 0)
>> +			goto err;
>
> The error case corrupts drvstate->pmcount
>
>> +		usbnet_dev->intf->needs_remote_wakeup =3D on;
>> +		usb_autopm_put_interface(usbnet_dev->intf);
>> +	}
>> +err:
>> +	return rv;
>> +}

Hello Oliver,

I finally got around to looking closer at this and you are of course
correct.  This is all my fault when I initially wrapped the
needs_remote_wakeup update in usb_autopm_{get,put}_interface,

And the problem is not only here in this new driver, but *everywhere* I
did this, including in cdc-wdm.  That driver doesn't have the counter t=
o
corrupt, but failing to update intf->needs_remote_wakeup if
usb_autopm_get_interface fails is still wrong. The get/put were only
added to make the change take effect immediately.  Things sort of worke=
d
fine before that, and ignoring a get error would only revert to that
older behaviour.

So I believe we should do the update unconditionally, and but skip
usb_autopm_put_interface if the get failed.  Accordingly, these
functions should always return 0 (not that there is anything currently
checking the return anyway).

I'll prepare patches for cdc-wdm, qmi_wwan and cdc_mbim.


Bj=C3=B8rn
