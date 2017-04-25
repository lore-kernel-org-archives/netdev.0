From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: qed*: debug infrastructures
Date: Tue, 25 Apr 2017 09:13:14 -0700
Message-ID: <c8751a31-f493-45c1-5bf2-596b367ea034@gmail.com>
References: <CY1PR0701MB1337FA26F1503FC9928B0340901F0@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>
To: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33221 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951353AbdDYQNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:13:22 -0400
Received: by mail-pg0-f65.google.com with SMTP id 63so12286685pgh.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:13:22 -0700 (PDT)
In-Reply-To: <CY1PR0701MB1337FA26F1503FC9928B0340901F0@CY1PR0701MB1337.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017 10:38 AM, Elior, Ariel wrote:
> Hi Dave,
> 
> According to the recent messages on the list indicating debugfs is not the way
> to go, I am looking for some guidance on what is. dpipe approach was
> mentioned as favorable, but I wanted to make sure molding our debug features to
> this infrastructure will result in something acceptable. A few points:
> 
> 1.
> One of our HW debug features is a signal recording feature. HW is configured to
> output specific signals, which are then continuously dumped into a cyclic
> buffer on host. There are ~8000 signals, which can be logically divided to ~100
> groups. I believe this can be modeled in dpipe (or similar tool) as a set of
> ~100 tables with ~80 entries each, and user would be able to see them all and
> choose what they like. The output data itself is binary, and meaningless to
> "the user". The amount of data is basically as large a contiguous buffer as
> driver can allocate, i.e. usually 4MB. When user selects the signals, and sets
> meta data regarding to mode of operations, some device configuration will have
> to take place. Does that sound reasonable?
> This debug feature already exists out of tree for bnx2x and qed* drivers and is
> *very* effective in field deployments. I would very much like to see this as an
> in-tree feature via some infrastructure or another.

By signals do you mean actual electrical signals coming from your chip's
pins/balls? FWIW, there is kind of something similar existing with ARM
Ltd's Embedded Trace Module which allows capturing a SoC's CPU activity
(loads/stores/pc progression etc.) using a high speed interface. You may
want to look at drivers/hwtracing/{coresight,stm}/ for examples on how
this interfaces with Linux' perf events subsystems. There are existing
trace buffers infrastructures and it sounds like your use case fits
nicely within the perf events framework here where you may want the
entire set or subset of these 8000 signals to be recorded in a buffer.


> 
> 2.
> Sometimes we want to debug the probe or removal flow of the driver. ethtool has
> the disadvantage of only being available once network device is available. If a
> bug stops the load flow before the ethtool debug paths are available, there is
> no way to collect a dump. Similarly, removal flows which hit a bug but do remove
> the network device, can't be debugged from ethtool. Does dpipe suffer from the
> same problem? qed* (like mlx*) has a common-functionality module. This allows
> creating debugfs nodes even before the network drivers are probed, providing a
> solution for this (debug nodes are also available after network driver removal).
> If dpipe does hold an answer here (e.g. provide preconfiguration which would
> kick in when network device registers) then we might want to port all of our
> register dump logic over there for this advantage. Does that sound reasonable?

Can you consider using tracing for that particular purpose with trace
filters that are specific to the device of interest? That should allow
you to get events down from the Linux device driver model all the way to
when your driver actually gets initialized. Is that an option?
-- 
Florian
