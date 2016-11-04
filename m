From: Sebastian Frias <sf84@laposte.net>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 15:01:45 +0100
Message-ID: <581C94C9.5080503@laposte.net>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com> <581C9273.906@free.fr>
 <20161104135752.GC3600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz26.laposte.net ([194.117.213.101]:57145 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934545AbcKDOZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 10:25:24 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout014 (Postfix) with ESMTP id 74A6B121331
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 15:01:47 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout014 (Postfix) with ESMTP id 65BEF121735
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 15:01:47 +0100 (CET)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
        by lpn-prd-vrout014 (Postfix) with ESMTP id 6156C121331
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 15:01:47 +0100 (CET)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
        by lpn-prd-vrin002 (Postfix) with ESMTP id 4338C5BF2AC
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 15:01:47 +0100 (CET)
In-Reply-To: <20161104135752.GC3600@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2016 02:57 PM, Andrew Lunn wrote:
>> Considering the ethernet DT bindings:
>>
>> https://www.kernel.org/doc/Documentation/devicetree/bindings/net/ethernet.txt
>>
>> Specifically, phy-mode values "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid".
>>
>> Assuming that "rxid" (rx internal delay) and "rx clock delay" are
>> in fact the same concept with different names, do you agree that
>> it would be unexpected for "rgmii rx clock delay" to be enabled
>> when a DTB specifies "rgmii" or "rgmii-txid" ?
> 
> I agree with you. But fixing it is likely to break boards which
> currently have "rgmii", but actually need the delay in order to work.
> 
> 	  Andrew
> 

I think you are right, if I disable the RX delay on 'drivers/net/phy/at803x.c'
I get RX errors when using the 'drivers/net/ethernet/aurora/nb8800.c' driver,
errors reported in function nb8800_poll()

if (IS_RX_ERROR(rxd->report))
{
   nb8800_rx_error(dev, rxd->report);
}

(this is on the same board Mason is discussing about)

Another thing to note is that 'drivers/net/ethernet/aurora/nb8800.c' is
currently checking PHY_INTERFACE_MODE_RGMII_TXID to add a TX clock output
delay.

Since a PHY, like the 'drivers/net/phy/at803x.c', will setup a TX delay if
phy-connection-type="rgmii-txid" on DT, the code in 'nb8800.c' may be adding
an additional (and possibly unwanted) delay, right?

Actually, I have a patch for 'nb8800.c' to remove the "additional" TX delay,
and I did not see regressions with it. I can post the patch as RFC if
you want.

One more thing, the "tx" and "rx" concepts are in reference to what?
Is "tx" at PHY driver to be matched by "rx" at Ethernet driver?

Best regards,

Sebastian
