From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] net/bonding: send arp in interval if no active slave
Date: Mon, 28 Sep 2015 09:31:35 -0400
Message-ID: <56094137.9030206@redhat.com>
References: <1439828583-27325-1-git-send-email-jarod@redhat.com> <20150817165500.GA21512@vps.falico.eu> <55D215F7.3080905@redhat.com> <55D22E64.6020807@redknee.com> <2649.1439838866@famine> <55D2494F.3020800@redknee.com> <20150901154157.GY504@gospo.home.greyhouse.net> <55E63065.8070906@redknee.com> <31529.1441292743@famine> <55E97AC6.6030106@redknee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Uwe Koziolek <uwe.koziolek@redknee.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E97AC6.6030106@redknee.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uwe Koziolek wrote:
> Am 03.09.2015 um 17:05 schrieb Jay Vosburgh:
>> Uwe Koziolek <uwe.koziolek@redknee.com> wrote:
>>
>>> On Tue, Sep 01, 2015 at 05:41 PM +0200, Andy Gospodarek wrote:
>>>> On Mon, Aug 17, 2015 at 10:51:27PM +0200, Uwe Koziolek wrote:
>>>>> On Mon, Aug 17, 2015 at 09:14PM +0200, Jay Vosburgh wrote:
>>>>>> Uwe Koziolek <uwe.koziolek@redknee.com> wrote:
...
>> I probably should have asked this in the beginning, but at what
>> range of arp_interval values does the problem manifest? If it's a race
>> condition with the switch update, I'd expect that only very small
>> arp_interval values would be affected.
>>
>> Also, your proposed comment wraps past 80 columns.
>>
>> -J
>>
> Only 500 msecs arp interval is used, no other values are checked.
> Wraps in patch are now removed.
>
> diff -up ./drivers/net/bonding/bond_main.c.orig
> ./drivers/net/bonding/bond_main.c
> --- ./drivers/net/bonding/bond_main.c.orig 2015-08-30 20:34:09.000000000
> +0200
> +++ ./drivers/net/bonding/bond_main.c 2015-09-04 11:59:05.755897182 +0200
> @@ -2795,6 +2795,17 @@ static bool bond_ab_arp_probe(struct bon
> return should_notify_rtnl;
> }
>
> + /* sometimes the forwarding tables of the switches are not updated
> + * fast enough. the first arp response after a slave change is received
> + * on the wrong slave.
> + * the arp requests will be retried 2 times on the same slave
> + */
> +
> + if (bond_time_in_interval(bond, curr_arp_slave->last_link_up, 2)) {
> + bond_arp_send_all(bond, curr_arp_slave);
> + return should_notify_rtnl;
> + }
> +
> bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
>
> bond_for_each_slave_rcu(bond, slave, iter) {

Jay, any further issues with this patch? I know Veaceslav was concerned 
about it breaking the logic for link state management if there's no 
current active slave for 2 * arp_interval, while Andy seemed okay with 
it, provided there was a comment explaining. Just looking at what might 
have to be done next here to keep heading towards a resolution.

Thanks much,

-- 
Jarod Wilson
jarod@redhat.com
