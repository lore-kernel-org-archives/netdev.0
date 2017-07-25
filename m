From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Tue, 25 Jul 2017 10:55:17 -0700
Message-ID: <E5207219-42E8-42FB-9E92-D3F424E2AD8C@gmail.com>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr> <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr> <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com> <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr> <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com> <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com> <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr> <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com> <eb09bda5-c972-0c2c-2693-982c02c8c87c@gmail.com> <1c00935b-3a3c-4268-db99-a0487ddece76@free.fr> <e2f4ef4a-c667-3bdf-e4ea-2767dc6a4922@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36045 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbdGYRzW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:55:22 -0400
Received: by mail-pf0-f193.google.com with SMTP id 1so5335331pfi.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:55:22 -0700 (PDT)
In-Reply-To: <e2f4ef4a-c667-3bdf-e4ea-2767dc6a4922@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On July 25, 2017 4:41:32 AM PDT, Mason <slash=2Etmp@free=2Efr> wrote:
>On 25/07/2017 12:51, Mason wrote:
>
>> Moving the call to phy_stop() down after all the MAC tear down
>> avoids the hang=2E
>>=20
>> As far as I understand, when we are shutting everything down,
>> we don't need the phy_state_machine to run asynchronously=2E
>> We can run it synchronously one last time after the delayed
>> stuff has been disabled=2E
>
>Below is my current WIP diff=2E (It conflates the two issues
>I've been discussing=2E Splitting the diff required=2E)
>
>Tested in interrupt mode:
>
># ip link set eth0 up
>[   11=2E107547] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change UP -> AN
>[   14=2E530329] nb8800 26000=2Eethernet eth0: Link is Up - 1Gbps/Full -
>flow control rx/tx
>[   14=2E538136] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change AN -> RUNNING
># ip link set eth0 down
>[   23=2E801018] nb8800 26000=2Eethernet eth0: Link is Down
># ip link set eth0 up
>[   28=2E740870] Atheros 8035 ethernet UP26000=2Enb8800-mii:04: PHY state
>change UP -> AN
>[   31=2E431528] nb8800 26000=2Eethernet eth0: Link is Up - 1Gbps/Full -
>flow control rx/tx
>[   31=2E439350] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change AN -> RUNNING
>
>Works as expected=2E

It does indeed, although this probably also contains your change that only=
 logs the PHY state machine transitions, which makes me wonder why the UP -=
> HALTED state is not logged?

>
>Tested in polling mode:
>
># ip link set eth0 up
>[   23=2E001199] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change UP -> AN
>[   24=2E024315] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change AN -> NOLINK
>[   27=2E064355] nb8800 26000=2Eethernet eth0: Link is Up - 1Gbps/Full -
>flow control rx/tx
>[   27=2E072156] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change NOLINK -> RUNNING
># ip link set eth0 down
>[   42=2E134617] nb8800 26000=2Eethernet eth0: Link is Down
># ip link set eth0 up
>[   48=2E381185] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change UP -> AN
>[   49=2E410976] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change AN -> NOLINK
>[   51=2E437686] nb8800 26000=2Eethernet eth0: Link is Up - 1Gbps/Full -
>flow control rx/tx
>[   51=2E445486] Atheros 8035 ethernet 26000=2Enb8800-mii:04: PHY state
>change NOLINK -> RUNNING
>
>Works as expected=2E
>
>Also tested on my old board, no regression seen=2E
>
>Can you confirm that the changes to drivers/net/phy/phy=2Ec
>look reasonable?

The flush is correct, but I am not sure about the explicit state change, i=
n two ways:

- in polling mode, we should already be reaching that state with the flush=
 call AFAICT
- in interrupt driven mode (phy_interrupt_is_valid or PHY_IGNORE_INTERRUPT=
) we do indeed need to make sure the HALTED state is reached

Not sure why I did not see the interrupt imbalance problem with phy_mac_in=
terrupt=2E=2E=2E

I am out today but will follow up tomorrow=2E thanks!

--=20
Florian
