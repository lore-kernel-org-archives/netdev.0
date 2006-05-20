From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Sat, 20 May 2006 09:58:45 +0200
Message-ID: <446ECC35.5050707@myri.com>
References: <20060517220218.GA13411@myri.com> <446D2CA7.2070009@myri.com> <200605191200.47132.arnd@arndb.de> <200605191309.30992.ak@suse.de> <446DE8CF.7050603@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	gallatin@myri.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932212AbWETH7S@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <446DE8CF.7050603@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Andi Kleen wrote:
>   
>> On Friday 19 May 2006 12:00, Arnd Bergmann wrote:
>>   
>>     
>>> On Friday 19 May 2006 04:25, Brice Goglin wrote:
>>>     
>>>       
>>>> dev_mc_upload() from net/core/dev_mcast.c does
>>>>
>>>> spin_lock_bh(&dev->xmit_lock);
>>>> __dev_mc_upload(dev);
>>>>
>>>> which calls dev->set_multicast_list(), which is
>>>> myri10ge_set_multicast_list()
>>>>
>>>> which calls myri10ge_change_promisc
>>>>
>>>> which calls myri10ge_send_cmd
>>>>       
>>>>         
>>> Hmm, if that is the only path where you call it, it may be
>>> helpful to change myri10ge_change_promisc to call a special
>>> atomic version of myri10ge_send_cmd then, while all others
>>> use the regular version, which you can then convert to
>>> do msleep as well.
>>>     
>>>       
>> Or just drop the xmit lock while you do that. As long as you
>> handle races with ->start_xmit yourself it's ok
>>   
>>     
>
> Looks like we can do that.
>   

Forget what I said. It's not that simple. __dev_mc_upload() is also
called from igmp6_group_added() (through dev_mc_add()). In this path,
there are two spin_lock_bh that are held:

igmp6_group_added(...)
    [...]
    spin_lock_bh(&mc->mca_lock);
    [...]
    dev_mc_add(...)

dev_mv_add(..)
    [...]
    spin_lock_bh(&dev->xmit_lock);
    [...]
    __dev_mc_upload(...)

We have actually seen this path being taken by adding a
    if (in_interrupt()) {
       printk("bad bad bad\n");
       dump_stack();
    }
in our myri10ge_send_cmd(...).

We are going to add a "sleepable" parameter to myri10ge_send_cmd() so
that only set_multicast_list() will use it with our previous udelay loop.

Brice
