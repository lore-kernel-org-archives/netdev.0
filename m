From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Mon, 25 Sep 2017 10:14:23 -0600
Message-ID: <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
References: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
 <b175f7ab-12b6-061a-4233-ba53641ef99b@gmail.com>
 <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
 <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:49367 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934227AbdIYQO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:14:26 -0400
Received: by mail-pg0-f44.google.com with SMTP id m30so4233011pgn.6
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:14:26 -0700 (PDT)
In-Reply-To: <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/24/17 11:27 PM, Eric Dumazet wrote:
> On Sun, 2017-09-24 at 20:05 -0600, David Ahern wrote:
>> On 9/24/17 7:57 PM, David Ahern wrote:
> 
>>> Hi Eric:
>>>
>>> I'm guessing the cost is in the rb_first and rb_next computations. Did
>>> you consider something like this:
>>>
>>>         struct rb_root *root
>>>         struct rb_node **p = &root->rb_node;
>>>
>>>         while (*p != NULL) {
>>>                 struct foobar *fb;
>>>
>>>                 fb = container_of(*p, struct foobar, rb_node);
>>>                 // fb processing
>> 		  rb_erase(&nh->rb_node, root);
>>
>>>                 p = &root->rb_node;
>>>         }
>>>
>>
>> Oops, dropped the rb_erase in my consolidating the code to this snippet.
> 
> Hi David
> 
> This gives about same numbers than method_1
> 
> I tried with 10^7 skbs in the tree :
> 
> Your suggestion takes 66ns per skb, while the one I chose takes 37ns per
> skb.

Thanks for the test.

I made a simple program this morning and ran it under perf. With the
above suggestion the rb_erase has a high cost because it always deletes
the root node. Your method 1 has a high cost on rb_first which is
expected given its definition and it is run on each removal. Both
options increase in time with the number of entries in the tree.

Your method 2 is fairly constant from 10,000 entries to 10M entries
which makes sense: a one time cost at finding rb_first and then always
removing a bottom node so rb_erase is light.

As for the change:

Acked-by: David Ahern <dsahern@gmail.com>
