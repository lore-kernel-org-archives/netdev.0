From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Thu, 15 Feb 2007 23:40:32 -0800
Message-ID: <45D55FF0.8090309@candelatech.com>
References: <20070216072928.GA1599@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57572 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932625AbXBPHjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 02:39:14 -0500
In-Reply-To: <20070216072928.GA1599@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 14-02-2007 22:27, Stephen Hemminger wrote:
>   
>> Ben found this but the problem seems pretty widespread.
>>
>> The following places are subject to deadlock between flush_scheduled_work
>> and the RTNL mutex. What can happen is that a work queue routine (like
>> bridge port_carrier_check) is waiting forever for RTNL, and the driver
>> routine has called flush_scheduled_work with RTNL held and is waiting
>> for the work queue to clear.
>>
>> Several other places have comments like: "can't call flush_scheduled_work
>> here or it will deadlock". Most of the problem places are in device close
>> routine. My recommendation would be to add a check for device netif_running in
>> what ever work routine is used, and move the flush_scheduled_work to the
>> remove routine.
>>
>> 8139too.c: rtl8139_close --> rtl8139_stop_thread
>> r8169.c:   rtl8169_down
>> cassini.c: cas_change_mtu
>> iseries_veth.c: veth_stop_connection
>> s2io.c: s2io_close
>> sis190.c: sis190_down
>>
>>     
>
> There is probably more than this...
>   

Maybe there should be something like an ASSERT_NOT_RTNL() in the 
flush_scheduled_work()
method?  If it's performance criticial, #ifdef it out if we're not 
debugging locks?

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


