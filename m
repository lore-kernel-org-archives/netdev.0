From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] bluetooth: hci_uart: add LL protocol serdev driver support
Date: Wed, 19 Apr 2017 15:47:23 -0500
Message-ID: <CAL_JsqKv=pYRTxE4H81DTiUqzgSU0tVDPKBQ+WPo=VJOBNTu9Q@mail.gmail.com>
References: <20170413150353.7389-1-robh@kernel.org> <20170413150353.7389-4-robh@kernel.org>
 <CAHCN7xLNcD1rmifEOyPhG2rpB_C81hsyzV9W2q6kCQkKa69sZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHCN7xLNcD1rmifEOyPhG2rpB_C81hsyzV9W2q6kCQkKa69sZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2017 at 3:11 PM, Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, Apr 13, 2017 at 10:03 AM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> Turns out that the LL protocol and the TI-ST are the same thing AFAICT.
>> The TI-ST adds firmware loading, GPIO control, and shared access for
>> NFC, FM radio, etc. For now, we're only implementing what is needed for
>> BT. This mirrors other drivers like BCM and Intel, but uses the new
>> serdev bus.
>>
>> The firmware loading is greatly simplified by using existing
>> infrastructure to send commands. It may be a bit slower than the
>> original code using synchronous functions, but the real bottleneck is
>> likely doing firmware load at 115.2kbps.
>
> I am using pdata-quirks to drive my wl1283 Bluetooth on a DM3730.  I
> have the Bluetooth set to 3000000 baud in pdata quirks.  Looking at
> the binding, I don't see an option to set the baudrate.  Is there (or
> will there) be a way to set the baud rate of the Bluetooth?

If you read hci_ti_probe, you will see it is already there. The
default is 3Mbps and the DT can override that with "max-speed". The
intent is that 3Mbps is the max the device can do and max-speed is
only for board or host limitations. Though I just checked the
datasheet on the 1835 and it can go up to 4364kbps. No datasheets for
wl1283, so I have no idea what the max is.

>> +static int hci_ti_probe(struct serdev_device *serdev)
>> +{
>> +       struct hci_uart *hu;
>> +       struct ll_device *lldev;
>> +       u32 max_speed = 3000000;

[...]

>> +       of_property_read_u32(serdev->dev.of_node, "max-speed", &max_speed);
>> +       hci_uart_set_speeds(hu, 115200, max_speed);
