From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 09 Jan 2014 17:06:29 -0800
Message-ID: <52CF4795.106@intel.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com> <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com> <1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com> <20140109164936.4b17cf38@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12822 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435AbaAJBGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 20:06:33 -0500
In-Reply-To: <20140109164936.4b17cf38@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/2014 4:49 PM, Stephen Hemminger wrote:
> On Thu, 9 Jan 2014 16:30:12 -0800
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> On Thu, Jan 9, 2014 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>
>>>
>>> Really, you'll have to explain in the changelog why you think this is
>>> safe, because I really do not see how this can be valid.
>>>
>>> I think I already said it was not safe at all...
>>>
>>> You could try a multiqueue NIC for some interesting effects.
>>>
>>
>> There is only one ingress queue, that is dev->ingress_queue, right?
>>
>> And since on ingress, the only possible qdisc is sch_ingress,
>> looking at ingress_enqueue(), I don't see anything so dangerous.
>>
>> As I said in the cover letter, I may still miss something in the qdisc
>> layer, but doesn't look like related with multiqueue. Mind to be more
>> specific?
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> I think what Eric is saying is that on a multi-queue NIC, multiple
> queues can be receiving packets and then sending them on to the ingress
> queue discipline. Up until your patch that code itself was protected
> by qdisc_lock and did not have to worry about any SMP issues. Now, any
> qdisc attached on ingress could run in parallel. This would break all
> the code in those queue disciplines. Think of the simplest case
> of policing.
> --

Just to re-iterate you need to go through each and every qdisc,
classifier, action and verify it is safe to run in parallel. Take
a look at how the skb lists are managed in the qdiscs. If we want
to do this we need to make these changes in some coherent way
because it touches lots of pieces.

Also your stats are going to get hosed none of the bstats, qstats
supports this. I'll send out the classifier set later tonight
if you want. I got stalled going through the actions.

Finally any global state in those qdiscs is going to drive performance
down so many of them would likely need to be redesigned.

.John
