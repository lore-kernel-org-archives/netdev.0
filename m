From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Question] Should `CAP_NET_ADMIN` be needed when opening
 `/dev/ppp`?
Date: Tue, 3 May 2016 18:01:53 +0200
Message-ID: <89c37154-ce09-18b9-93e2-0696b508976f@stressinduktion.org>
References: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
 <20160503101240.GA1304@alphalink.fr>
 <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com>
 <1462274614.1336993.596603129.675ECADD@webmail.messagingengine.com>
 <20160503155157.GB1304@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	Wang Shanker <shankerwangmiao@gmail.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160503155157.GB1304@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.05.2016 17:51, Guillaume Nault wrote:
> On Tue, May 03, 2016 at 01:23:34PM +0200, Hannes Frederic Sowa wrote:
>> On Tue, May 3, 2016, at 12:35, Richard Weinberger wrote:
>>> On Tue, May 3, 2016 at 12:12 PM, Guillaume Nault <g.nault@alphalink.fr>
>>> wrote:
>>>> On Sun, May 01, 2016 at 09:38:57PM +0800, Wang Shanker wrote:
>>>>> static int ppp_open(struct inode *inode, struct file *file)
>>>>> {
>>>>>       /*
>>>>>        * This could (should?) be enforced by the permissions on /dev/ppp.
>>>>>        */
>>>>>       if (!capable(CAP_NET_ADMIN))
>>>>>               return -EPERM;
>>>>>       return 0;
>>>>> }
>>>>> ```
>>>>>
>>>>> I wonder why CAP_NET_ADMIN is needed here, rather than leaving it to the
>>>>> permission of the device node. If there is no need, I suggest that the
>>>>> CAP_NET_ADMIN check be removed.
>>>>>
>>>> If this test was removed here, then it'd have to be added again in the
>>>> PPPIOCNEWUNIT ioctl, at the very least, because creating a netdevice
>>>> should require CAP_NET_ADMIN. Therefore that wouldn't help for your
>>>> case.
>>>> I don't know why the test was placed in ppp_open() in the first place,
>>>> but changing it now would have side effects on user space. So I'd
>>>> rather leave the code as is.
>>>
>>> I think the question is whether we really require having CAP_NET_ADMIN
>>> in the initial namespace and not just in the current one.
>>> Is ppp not network namespace aware?
>>
>> I agree, ns_capable(net->user_ns, CAP_NET_ADMIN), would probably make
>> more sense.
>>
> I guess you assume net is set to current->nsproxy->net_ns here.
> Why about ns_capable(current_user_ns(), CAP_NET_ADMIN)?
> 
> From my understanding of the code (I currently have no practical
> experience with user namespaces), net->user_ns points to the userns in
> which the current netns was created, while current_user_ns() refers to
> the caller's userns. Shouldn't we check the later? Otherwise, any
> process running in the netns would have the same capabilities regarding
> PPP ioctls().

We want to test our (*current) capability in the user namespace the net
namespace was created. current is implied here.

If you create a new user_namespace ontop the same network stack you
shouldn't have those capabilities, otherwise you can elevate capabilities.

Bye,
Hannes
