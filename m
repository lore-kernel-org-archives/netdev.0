From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v2 2/7] USB: serial: handle suspend failure path correctly
Date: Fri, 15 Mar 2013 11:04:14 +0800
Message-ID: <CACVXFVO5RioYUQf7aA2_M=yNcBf=aVM2zLZAqu+dU9okUSmXHw@mail.gmail.com>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
	<1362672924-22975-3-git-send-email-ming.lei@canonical.com>
	<20130314111010.GA15776@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Johan Hovold <jhovold@gmail.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <20130314111010.GA15776@localhost>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 14, 2013 at 7:10 PM, Johan Hovold <jhovold@gmail.com> wrote=
:
> On Fri, Mar 08, 2013 at 12:15:19AM +0800, Ming Lei wrote:
>> This patch kills traffic even though type->suspend returns
>> failure inside usb_serial_suspend from system sleep context
>> because USB core ignores the failiure and lets system sleep
>> go ahread, so the serial URB traffic need to be killed
>> in this case.
>>
>> Cc: Johan Hovold <jhovold@gmail.com>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>>  drivers/usb/serial/usb-serial.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/usb/serial/usb-serial.c b/drivers/usb/serial/us=
b-serial.c
>> index a19ed74..9d0b9c8 100644
>> --- a/drivers/usb/serial/usb-serial.c
>> +++ b/drivers/usb/serial/usb-serial.c
>> @@ -1142,10 +1142,11 @@ int usb_serial_suspend(struct usb_interface =
*intf, pm_message_t message)
>>
>>       if (serial->type->suspend) {
>>               r =3D serial->type->suspend(serial, message);
>> -             if (r < 0) {
>> +             if (r < 0 && PMSG_IS_AUTO(message)) {
>>                       serial->suspending =3D 0;
>>                       goto err_out;
>>               }
>> +             /* TODO: resume() might need to handle suspend failure=
 */
>>       }
>>
>>       for (i =3D 0; i < serial->num_ports; ++i) {
>
> Sorry for the late reply.
>
> The usb-serial subdriver suspend callbacks do not and must not return
> non-zero if !PMSG_IS_AUTO(message) so adding code to handle that case
> merely obfuscates this fact.
>
> I'd rather see this documented with a comment just as Bj=F8rn suggest=
ed
> for cdc_mbim and qmi_wwan.

No problem, will do it in v3.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
