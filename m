From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v8 net-next 5/7] net: simple poll/select
 low latency socket poll
Date: Tue, 04 Jun 2013 11:52:45 +0300
Message-ID: <51ADAADD.4030209@linux.intel.com>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
	<20130603080200.18273.52073.stgit@ladj378.jer.intel.com>
	<1370265324.24311.136.camel@edumazet-glaptop>
	<51ACA15C.4060101@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51ACA15C.4060101@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/06/2013 16:59, Eliezer Tamir wrote:
> On 03/06/2013 16:15, Eric Dumazet wrote:
>> On Mon, 2013-06-03 at 11:02 +0300, Eliezer Tamir wrote:
>>>       sock = file->private_data;
>>> -    return sock->ops->poll(file, sock, wait);
>>> +
>>> +    poll_result = sock->ops->poll(file, sock, wait);
>>> +
>>> +    if (!(poll_result & (POLLRDNORM | POLLERR | POLLRDHUP |
>>> POLLHUP)) &&
>>> +        sk_valid_ll(sock->sk) && sk_poll_ll(sock->sk, 1))
>>> +            poll_result = sock->ops->poll(file, sock, NULL);
>>> +
>>> +    return poll_result;
>>>   }
>>>
>>>   static int sock_mmap(struct file *file, struct vm_area_struct *vma)
>>>
>>
>>
>> In fact, for TCP, POLLOUT event being ready can also be triggered by
>> incoming messages, as the ACK might allow the user application to push
>> more data in the write queue.
>>
>> And you might check wait->_key to avoid testing flags that user is not
>> interested into.
>
> yes, comparing to _key is more correct.
> In any case this needs to be completely rewritten for support for
> working well with a large number of sockets.
>

Is it possible for wait to be NULL? (do we need to check for that?)
I see that poll_does_not_wait() checks for that, but I could not find
anywhere this is actually done.

-Eliezer


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
