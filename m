From: Jon Ringle <jon@ringle.org>
Subject: Re: Fwd: Ethernet controller not starting
Date: Tue, 4 Mar 2014 10:08:11 -0500
Message-ID: <CAMwGMjysvR7VqRXeD4GCk5OR=SnXVjmLDLCkdFK_KSAazky7aw@mail.gmail.com>
References: <71F7AD3B89A7BF1E126CB3B1@C9882B18C00BA04428877CD4>
	<CAMwGMjwtZVPVaENWqNODPqkM4jAAOsLPrz8_xzRBgGP6_-_usQ@mail.gmail.com>
	<CAMwGMjxO3eV1t9VrBbL3SecwOJPs2rESGS6VEH60tne4Dx8tVw@mail.gmail.com>
	<09FBC53C1B46AC96B6483AA4@172.22.2.41>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	rafael.j.wysocki@intel.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Prabhakar Lad <prabhakar.csengg@gmail.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <09FBC53C1B46AC96B6483AA4@172.22.2.41>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 4, 2014 at 9:06 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Hi Jon,
>
> [Now also cc'ed Prabhakar Lad]
>
>
> --On March 04, 2014 07:34 -0500 Jon Ringle <jon@ringle.org> wrote:
>
>> On Tue, Mar 4, 2014 at 4:06 AM, Christian Riesch
>> <christian.riesch@omicron.at> wrote:
>>>
>>> [cc'ed netdev and davinci-linux-open-source]
>>>
>>>
>>> --On March 03, 2014 19:39 -0500 Jon Ringle <jon@ringle.org> wrote:
>>>
>>>> On Mon, Mar 3, 2014 at 6:43 PM, Rafael J. Wysocki <rjw@rjwysocki.net>
>>>> wrote:
>>>>>
>>>>>
>>>>> On Monday, March 03, 2014 02:41:01 PM Jon Ringle wrote:
>>>>>>
>>>>>>
>>>>>> I'm working on porting an ARM board from linux-3.10 to linux-3.12 (now
>>>>>> the latest LTS kernel).
>>>>>> I found that Ethernet controller on the board no longer comes up on
>>>>>> linux-3.12. I was able to bisect the issue I'm having to the following
>>>>>> commit:
>>>>>>
>>>>>> >   45f0a85c8258741d11bda25c0a5669c06267204a is the first bad commit
>>>>>> >   commit 45f0a85c8258741d11bda25c0a5669c06267204a
>>>>>> >   Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>>>>>> >   Date:   Mon Jun 3 21:49:52 2013 +0200
>>>>>> >
>
> [...]
>
>>>>>>
>>>>>> Can anyone offer any suggestions on what I should be looking for to
>>>>>> fix this on my board?
>>>>>
>>>>>
>>>>>
>>>>> Any pointers to the driver in question?
>>>>
>>>>
>>>>
>>>> drivers/net/ethernet/ti/davinci_emac.c
>>>>
>>>
>>> Hi Jon,
>>> I have successfully used the davinci_emac driver on a custom board with
>>> an AM1808 SoC with Kernel 3.13 a few weeks ago. So at least 3.13 should
>>> work. Did you try more recent kernel versions than 3.12?
>>
>>
>> I have not tried 3.13, but will do so today. Could I get a copy of
>> your .config for comparison purposes?
>>
>
> I would like to apologize, apparently my testing with 3.13 was quite bad.
> Ethernet comes up on my board and works fine after booting, but I can easily
> reproduce your problem by just doing ifconfig eth0 down /ifconfig eth0 up
> (which should call emac_dev_stop/emac_dev_open).
>
> # ifconfig eth0 up
> genirq: Flags mismatch irq 33. .....
>
> So probably one of your start scripts (or dhcp or similar) does some
> ifconfig down/up, which then fails.
>
> I had a look at the code again, emac_dev_open requests the interrupts,
> whereas emac_dev_stop does not free them. If emac_dev_open is then called
> again by ifconfig eth0 up, it tries to request the interrupts again,
> resulting in the error above.
>
> I think the problem is a regression caused by
>
> Commit  6892b41d9701283085b655c6086fb57a5d63fa47
> net: davinci: emac: Convert to devm_* api
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>
> This patch replaces request_irq() by devm_request_irq() in emac_dev_open and
> removes free_irq() from emac_dev_stop. But since emac_dev_open is called
> every time we do an ifconfig eth0 up, it tries to request the interrupts
> again and again and again (and fails).
>
> So I guess the correct solution would be to move the calls of
> devm_request_irq() to davinci_emac_probe(). I will send a patch to netdev,
> it solves the problem on my board.

The posted patch also resolves the issue on my board. Thanks!

Jon
