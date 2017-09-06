From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [RFC net-next] net: sch_clsact: add support for global per-netns
 classifier mode
Date: Wed, 6 Sep 2017 13:14:10 +0300
Message-ID: <98984f98-8de6-291f-eba7-13cc36aebcf4@cumulusnetworks.com>
References: <1504615701-20912-1-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpUYGH4BQ-ZUShbRAy6aJD2fYuM+oc_kWYyQ51n+===CQw@mail.gmail.com>
 <CAJieiUj_-o-Cg2AzN5b0vrdnBD69ryMmpu4fcC64-MHEmQ-u4g@mail.gmail.com>
 <59AF291E.90508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34186 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752241AbdIFKOO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:14:14 -0400
Received: by mail-wm0-f44.google.com with SMTP id 137so26957518wmj.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 03:14:13 -0700 (PDT)
In-Reply-To: <59AF291E.90508@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/17 01:45, Daniel Borkmann wrote:
> On 09/06/2017 12:01 AM, Roopa Prabhu wrote:
>> On Tue, Sep 5, 2017 at 11:18 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Tue, Sep 5, 2017 at 5:48 AM, Nikolay Aleksandrov
>>> <nikolay@cumulusnetworks.com> wrote:
>>>> Hi all,
>>>> This RFC adds a new mode for clsact which designates a device's egress
>>>> classifier as global per netns. The packets that are not classified for
>>>> a particular device will be classified using the global classifier.
>>>> We have needed a global classifier for some time now for various
>>>> purposes and setting the single bridge or loopback/vrf device as the
> 
> Can you elaborate a bit more on the ... "we have needed a global
> classifier for some time now for various purposes".
> 
>>>> global classifier device is acceptable for us. Doing it this way avoids
>>>> the act/cls device and queue dependencies.
>>>>
>>>> This is strictly an RFC patch just to show the intent, if we agree on
>>>> the details the proposed patch will have support for both ingress and
>>>> egress, and will be using a static key to avoid the fast path test when no
>>>> global classifier has been configured.
>>>>
>>>> Example (need a modified tc that adds TCA_OPTIONS when using q_clsact):
>>>> $ tc qdisc add dev lo clsact global
>>>> $ tc filter add dev lo egress protocol ip u32 match ip dst 4.3.2.1/32 action drop
>>>>
>>>> the last filter will be global for all devices that don't have a
>>>> specific egress_cl_list (i.e. have clsact configured).
>>>
>>> Sorry this is too ugly.
> 
> +1
> 
>>> netdevice is still implied in your command line even if you treat it
>>> as global. It is essentially hard to bypass netdevice layer since
>>> netdevice is the core of L2 and also where everything begins.
>>>
>>> Maybe the best we can do here is make tc filters standalone
>>> as tc actions so that filters can exist before qdisc's and netdevices.
>>> But this probably requires significant works to make it working
>>> with both existing non-standalone and bindings standalones
>>> with qdisc's.
>>
>> yes, like Nikolay says we have been discussing this as well. Nikolay's
>> patch is a cleaver and most importantly non-invasive
>> way today given the anchor point for tc rules is a netdev. we have
>> also considered a separate implicit tc anchor device.
> 
> Seems ugly just as well. :( Hmm, why not just having the two list
> pointers (ingress, egress list) in the netns struct and when
> something configures them to be effectively non-zero, then devices
> in that netns could automatically get a clsact and inherit the
> lists from there such that sch_handle_ingress() and sch_handle_egress()
> require exactly zero changes in fast-path. You could then go and
> say that either you would make changes to clsact for individual
> devices immutable when they use the 'shared' list pointers, or then
> duplicate the configs when being altered from the global one. Would
> push the complexity to control path only at least. Just a brief
> thought.

Sure, this is a nice refinement, if we decide to continue with the idea of a global
clsact filter I'll push it all to the control path.

Thanks,
 Nik
