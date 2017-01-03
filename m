From: Ansis Atteka <aatteka@nicira.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Mon, 2 Jan 2017 16:40:56 -0800
Message-ID: <CAA=3Oqn1i0cFDw1yi=vWJuU=w-N+8T7i3+xx9qQtrQCatAi+8Q@mail.gmail.com>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com> <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net> <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
 <CAA=3Oqn5_5w+vrg9_7UtZ-5BEbZ9Pm=qdX3WoVZKaAkxcMXYXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "mlord@pobox.com" <mlord@pobox.com>,
        "greg@kroah.com" <greg@kroah.com>,
        "romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Ansis Atteka <aatteka@ovn.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:33300 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755610AbdACAk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 19:40:58 -0500
Received: by mail-yw0-f174.google.com with SMTP id r204so277708609ywb.0
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 16:40:57 -0800 (PST)
In-Reply-To: <CAA=3Oqn5_5w+vrg9_7UtZ-5BEbZ9Pm=qdX3WoVZKaAkxcMXYXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 31, 2016 at 4:07 PM, Ansis Atteka <aatteka@nicira.com> wrote:
> On Wed, Nov 30, 2016 at 3:58 AM, Hayes Wang <hayeswang@realtek.com> wrote:
>> Mark Lord <mlord@pobox.com>
>> [...]
>>> > Not sure why, because there really is no other way for the data to
>>> > appear where it does at the beginning of that URB buffer.
>>> >
>>> > This does seem a rather unexpected burden to place upon someone
>>> > reporting a regression in a USB network driver that corrupts user data.
>>>
>>> If you are the only person who can actively reproduce this, which
>>> seems to be the case right now, this is unfortunately the only way to
>>> reach a proper analysis and fix.
>>
>> I have tested it with iperf more than five days without any error.
>> I would think if there is any other way to reproduce it.
>>

I think that I am getting closer to the root cause of this bug. Also,
I have a workaround that at least makes r8152 functionally stable in
my Dell TB15 dock. Mark, would you mind giving a chance to the patch
that I have in the bottom of this email to see if it helps your issue
too (you might have to tweak those settings slightly differently if
you use something else than USB 3.0)

Long story short - what I observed in Wireshark is that if there are
more than ~10 Ethernet frames *close together to each other* then the
data corruption bug starts to express itself. If there are ~15 or more
Ethernet frames close together to each other then the XHCI starts to
emit the "ERROR Transfer event TRB DMA ptr not part of current TD
ep_index 2 comp_code 13" error message and r8152 driver gets toasted.
Hayes, in your iperf reproduction environment did you
1) connect sender and receiver directly with an Ethernet cable?
2) use iperf's TCP mode instead of UDP mode, because I believe that
with UDP mode packets are more likely to be sparsely distributed?
Also, this bug is way easier to reproduce when IP fragmentation kicks
in because IP fragments are typically sent out very close to each
other.
3) were you plugging your USB Ethernet dongle in USB 3.0 port or
whatever Mark was using? It seems that each USB mode has different
coalesce parameters and yours might have work "out of box"?


While I would not call this a proper fix, because it simply reduces
coalescing timeouts by order of 10X and most likely does not eliminate
security aspects of the bug, it at least made my system functionally
stable and I don't see either of those two bugs in my setup anymore:

git diff
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c254248..4979690 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -365,9 +365,9 @@
 #define PCUT_STATUS            0x0001

 /* USB_RX_EARLY_TIMEOUT */
-#define COALESCE_SUPER          85000U
-#define COALESCE_HIGH          250000U
-#define COALESCE_SLOW          524280U
+#define COALESCE_SUPER          8500U
+#define COALESCE_HIGH          25000U
+#define COALESCE_SLOW          52428U

 /* USB_WDT11_CTRL */
 #define TIMER11_EN             0x0001
