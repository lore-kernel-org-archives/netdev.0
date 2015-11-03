From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 03 Nov 2015 18:32:12 +0100
Message-ID: <5638EF9C.9070503@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de>	<201511021916.18117.marex@denx.de>	<666821254.20151102231521@cogentembedded.com>	<201511022125.47892.marex@denx.de>	<CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>	<56389C38.4080508@pengutronix.de>	<CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>	<5638CF74.7030001@pengutronix.de> <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marek Vasut <marex@denx.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:43302 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbbKCRcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:32:22 -0500
In-Reply-To: <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/03/2015 05:10 PM, Aleksander Morgado wrote:
>>> or the duplex TX/RX setup for channels
>>> (channels are either RX or TX, not both), or the local
>>> echoing/loopback (which wouldn't make much sense for TX-only
>>> channels).
>>
>> Local echo/loopback comes in two flavours:
>> - Other socket receive local generate frames, too.
>>   This is interesting if you want to merge two ARINC node on single
>>   device.
> 
> I'd actually love having this for a simulator setup I use where I
> currently physically connect cables from a TX channel in one adapter
> to a RX channel in another adapter. But I'm not sure there's a
> specific real usecase for that apart from testing purposes.

Once you have ever used this functionalities you will start to think beyond.

It's a matter of (stress-)testing your applications after build on virtual
CAN/ARINC interfaces. You will start to use the can-gw to route and/or modify
frames between interfaces. You have all the tools to display/log/visualize and
replay data. There's a wireshark plugin for PF_CAN you can easily adapt to
present ARINC data, etc.

So when thinking about using PF_CAN as ARINC429 base ...

This is the CAN frame structure:

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/can.txt?h=linux-4.2.y#n264

    struct can_frame {
            canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
            __u8    can_dlc; /* frame payload length in byte (0 .. 8) */
            __u8    __pad;   /* padding */
            __u8    __res0;  /* reserved / padding */
            __u8    __res1;  /* reserved / padding */
            __u8    data[8] __attribute__((aligned(8)));
    };


So what about defining an arinc429_frame like this:

    struct a429_frame {
            __u32   label;   /* ARINC 429 label */
            __u8    length;  /* always set to 3 */
            __u8    __pad;   /* padding */
            __u8    __res0;  /* reserved / padding */
            __u8    __res1;  /* reserved / padding */
            __u8    data[8] __attribute__((aligned(8)));
    };

Don't know if your suggestion

+ * ARINC packet:
+ *
+ * .-.---.------.---.-----.
+ * |P|SSM| Data |SDI|Label|
+ * '-'---'------'---'-----'
+ *  3 3 2 2....1 1 9 8...0
+ *  1 0 9 8    1 0
+ */
+
+/**
+ * struct arinc429_frame - basic ARINC429 frame structure
+ * @label:	ARINC429 label
+ * @data:	ARINC429 P, SSM, DATA and SDI
+ */
+struct arinc429_frame {
+	__u8	label;		/* 8 bit label */
+	__u8	data[3];	/* Up-to 23 bits are valid. */
+};

is really handy to use for arinc application programmers.

It looks like you need to shift the stuff in user space every time.

So you might better think of something like this:

    struct a429_frame {
            __u32   label;   /* ARINC 429 label */
            __u8    length;  /* always set to 8 */
            __u8    __pad;   /* padding */
            __u8    __res0;  /* reserved / padding */
            __u8    __res1;  /* reserved / padding */
            __u32   data __attribute__((aligned(8)));
            __u8    p;       /* p */
            __u8    ssm;     /* ssm */
            __u8    sdi;     /* sdi */
            __u8    __end;   /* padding */
    };

Good thing would be that you can directly see the content in logfiles and you
can easily modify the content on the fly by can-gw.

Of course the arinc netdevice driver would have to take care to do the correct
rx/tx whatever. But routing and processing arinc content through the CAN stack
does not seem to be a bad idea IMO.

Regards,
Oliver
