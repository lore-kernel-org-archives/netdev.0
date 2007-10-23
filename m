From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: Regression in current git - Network Manager fails (bisected)
Date: Tue, 23 Oct 2007 17:09:33 +0400
Message-ID: <471DF28D.3030904@sw.ru>
References: <20071022005857.GA6317@nineveh.local> <471C6BEC.4010604@sw.ru> <1193068645.30205.22.camel@localhost.localdomain> <20071023121123.GA8125@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:64400 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751148AbXJWNHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 09:07:04 -0400
In-Reply-To: <20071023121123.GA8125@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Dan Williams <dcbw@redhat.com> 2007-10-22 11:57
>> On Mon, 2007-10-22 at 13:22 +0400, Denis V. Lunev wrote:
>>> We have spent some time with the problem with Alexey and there are no 
>>> guesses for now.
>>>
>>> Is it possible to name exact version of Network Manager and all 
>>> libraries related + provide us an output of strace with full buffers 
>>> send/received from netlink. Something like
>>>      strace -v -x -s 32768 <nm>
>> NM uses netlink in two places; libnl (from Thomas Graf) and some custom
>> code for listening for interface up/down events and wireless events.
>>
>> It looks like that code comes from libnl's lib/handlers.c where it
>> thinks the received message is invalid.
>>
>> I'm pretty sure the code that checks carrier status of the device isn't
>> libnl code; so maybe the error message (which should get fixed of
>> course) isn't in the same path as the link detection.
>>
>> The link detection comes from src/nm-netlink-monitor.c, so maybe we
>> should look at debugging there.
> 
> The patch introduced a change in semantics because it removed the
> special ACK handling after a dump was started.
> 
> I will look into this.
> 

I have reproduced the problem with one-line test.
     ./nl-route-get 192.168.1.1
The problem is with this message:

-- Debug: Sent Message:
--------------------------   BEGIN NETLINK MESSAGE 
---------------------------
   [HEADER] 16 octets
     .nlmsg_len = 20
     .nlmsg_type = 18 <route/link>
     .nlmsg_flags = 773 <REQUEST,ACK,ROOT,MATCH>
     .nlmsg_seq = 1193143772
     .nlmsg_pid = 8233
   [PAYLOAD] 16 octets
     00 1d fa 20 00 00 00 00 81 0e 02 00 00 00 00 00       ... ............
---------------------------  END NETLINK MESSAGE 
---------------------------
it starts dump and requests ACK.

Regards,
	Den
