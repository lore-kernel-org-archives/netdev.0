From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Network cooling device and how to control NIC speed on thermal
 condition
Date: Tue, 25 Apr 2017 15:17:57 +0200
Message-ID: <20170425131757.GD26241@lunn.ch>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 10:36:28AM +0200, Waldemar Rymarkiewicz wrote:
> Hi,
> 
> I am not much aware of linux networking architecture so I'd like to
> ask first before will start to dig into the code. Appreciate any
> feedback.
> 
> I am looking on Linux thermal framework and on how to cool down the
> system effectively when it hits thermal condition. Already existing
> cooling methods cpu_cooling and clock_cooling are good. However, I
> wanted to go further and dynamically control also a switch ports'
> speed based on thermal condition. Lowering speed means less power,
> less power means lower temp.
> 
> Is there any in-kernel interface to configure switch port/NIC from other driver?

Hi Waldemar

Linux models switch ports as network interfaces, so mostly, there is
little difference between a NIC and a switch port. What you define for
one, should work for the other. Mostly.

However, i don't think you need to be too worried about the NIC level
of the stack. You can mostly do this higher up in the stack. I would
expect there is a relationship between Packets per Second and
generated heat. You might want the NIC to give you some sort of
heating coefficient, 1PPS is ~ 10uC. Given that, you want to throttle
the PPS in the generic queuing layers. This sounds like a TC filter.
You have userspace install a TC filter, which is a net_cooling device.

This however does not directly work for so called 'fastpath' traffic
in switches. Frames which ingress one switch port and egress another
switch port are mostly never seen by Linux. So a software TC filter
will not affect them. However, there is infrastructure in place to
accelerate TC filters by pushing them down into the hardware. So the
same basic concept can be used for switch fastpath traffic, but
requires a bit more work.

    Andrew
