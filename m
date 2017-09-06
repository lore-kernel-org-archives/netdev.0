From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Wed, 6 Sep 2017 12:28:19 -0700
Message-ID: <2d12dbb5-17c9-a0a5-1345-6aba81eca7b5@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
 <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
 <7b1c1dc9-b6e3-a1bd-2e36-474946741a79@gmail.com>
 <927413e9-4f1f-963c-2d3a-5a88de2eac9e@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35392 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbdIFT20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 15:28:26 -0400
Received: by mail-wm0-f47.google.com with SMTP id f199so12798892wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 12:28:25 -0700 (PDT)
In-Reply-To: <927413e9-4f1f-963c-2d3a-5a88de2eac9e@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 07:55 AM, Mason wrote:
> On 31/08/2017 21:18, Florian Fainelli wrote:
> 
>> On 08/31/2017 12:09 PM, Mason wrote:
>>
>>> 1) nb8800_link_reconfigure() calls phy_print_status()
>>> which prints the "Link down" and "Link up" messages
>>> to the console. With the patch reverted, nothing is
>>> printed when the link goes down, and the result is
>>> random when the link comes up. Sometimes, we get
>>> down + up, sometimes just up.
>>
>> Nothing printed when you bring down the network interface as a result of
>> not signaling the link down, there is a small nuance here.
> 
> Let me first focus on the "Link down" message.
> 
> Do you agree that such a message should be printed when the
> link goes down, not when the link comes up?

The question is not so much about printing the message rather than a)
having the adjust_link callback be called and b) having this particular
callback correctly determine if a "change" has occurred, but let's focus
on the notification too. Printing the message is a consequence of these
two conditions and that's what matters.

There is not unfortunately a hard and fast answer it's clearly a
philosophical problem here.

The link is not physically down, the cable is still plugged so
generating a link down even is not necessarily correct. It would be
convenient for network manager programs, just like it is for network
drivers to treat it as such because that allows them to act like if the
cable was unplugged, which may be a good way to perform a number of
actions including but not limited to: entering a low power state,
re-initialization parts of the Ethernet MAC that need it (DMA, etc.,
etc.). That does not appear to be an absolute requirement for most, if
not all drivers since it changed after 3.4 and no one did bat an eye
about it.

Upon bringing the interface back up again, same thing, if the cable was
not disconnected should we just generate a link UP event, and if we do
that, are we going to confuse any network manager application?
Generating a link transition DOWN -> UP is certainly helpful for any
network application in that they do not need to keep any state just like
it clearly indicates a change was detected.

> 
> Perhaps the issue is that the 2 following cases need to be
> handled differently:
> A) operator sets link down on the command-line

This is already handled differently since when you administratively
bring down an interface you call ndo_stop() which will be doing a
phy_stop() + phy_disconnect() which result in stopping the PHY state
machine and disconnecting from the PHY.

> B) asynchronous event makes link go down (peer is dead, cable is cut, etc)
> 
> In B) the PHY state machine keeps on running, and eventually
> calls adjust_link()

Correct.

> 
> In A) the driver calls phy_stop() and phy_disconnect() and
> therefore adjust_link() will not be called?

That is the current behavior (after the revert) and we can always change
it if deemed necessary, problem is, this broke for two people (one still
being discussed as of right now), so at this point I am very wary of
making any changes without more testing. I really need to get one of
these PHY interrupts wired to one of my boards or create a software
model of such a configuration before accepting new changes in that area.

Thank you
-- 
Florian
