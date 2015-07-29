From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: switchdev: restrict vid range abstraction
Date: Wed, 29 Jul 2015 15:14:05 -0400 (EDT)
Message-ID: <117624450.145106.1438197245281.JavaMail.zimbra@savoirfairelinux.com>
References: <1437954348-11859-1-git-send-email-vivien.didelot@savoirfairelinux.com> <CAE4R7bA5jh3Rgn_U1Sit3qW+i2vKNE++c9TYTJ8sp5j8h=awbw@mail.gmail.com> <20150729.112842.1871916445536378243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev <netdev@vger.kernel.org>,
	jiri@resnulli.us, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729.112842.1871916445536378243.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Scott, David,

On Jul 29, 2015, at 2:28 PM, David davem@davemloft.net wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> Date: Wed, 29 Jul 2015 00:31:44 -0700
> 
>> Since the netlink request (for example vlan add) includes the range,
>> I'm not seeing how we can response with success for the satisfied
>> vlans in the range, and also respond with an error for the unsatisfied
>> vlans in the range.   In other words, from the netlink msgs
>> perspective, we need to treat a vlan range as all-or-nothing.  So in
>> your example, if hw can't add vlan 2, we fail the entire request to
>> add range 2-5.  This is where the prepare phase checks to make sure
>> the entire request can be satisfied before committing to hw.

I made this change in order to start restricting the bridge abstraction
to switchdev, since IMHO its info flags do not add much value to the
switch chip drivers perspective.

While a range might be convenient to a user, exposing it to drivers is
likely to end up writing the same vid_begin to vid_end for loop.

> This was my concern with the change as well.
> 
> The user asked for the range to be installed, so if any portion
> of it cannot be done we must not make any changes to the HW
> configuration and fail the entire request.

I understand the concern with the netlink request.

However, this can be confusing to someone. With the previous example:

    bridge vlan add dev port0 vid 2-5 master

must fail for the entire range (due to the single netlink request). But:

    bridge vlan add dev port0 vid 2 master

will silently fallback to software VLAN (assuming that the driver
correctly returned -EOPNOTSUPP in the prepare phase). In other words, no
changes has been committed to the hardware.

Thanks,
-v
