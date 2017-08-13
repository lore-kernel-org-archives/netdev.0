From: Wei Wang <weiwan@google.com>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Sun, 13 Aug 2017 13:56:30 -0700
Message-ID: <CAEA6p_BtBdPviFVRC4UoJchbz7eH9fM=KDihYA3zUQebmNBpdA@mail.gmail.com>
References: <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
 <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
 <20170812180129.GA31700@splinter> <CAEA6p_Cngs9Nx9OZ15oRMu_43oZTYHjzcw2vzgemfEyh_g0nNA@mail.gmail.com>
 <61d95fe2-edfd-9fc4-5e21-5b96e4e03c9f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ido Schimmel <idosch@idosch.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Martin KaFai Lau <kafai@fb.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61d95fe2-edfd-9fc4-5e21-5b96e4e03c9f@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Looking at my patch to move host routes from loopback to device with the
> address, I have this:
>
> @@ -2789,7 +2808,8 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
>         const struct arg_dev_net *adn = arg;
>         const struct net_device *dev = adn->dev;
>
> -       if ((rt->dst.dev == dev || !dev) &&
> +       if ((rt->dst.dev == dev || !dev ||
> +            (netdev_unregistering(dev) && rt->rt6i_idev->dev == dev)) &&
>             rt != adn->net->ipv6.ip6_null_entry &&
>             (rt->rt6i_nsiblings == 0 ||
>              (dev && netdev_unregistering(dev)) ||

As you explained earlier, after your patch, all entries in the fib6
tree will have rt->dst.dev be the same as rt->rt6i_idev->dev except
those ones created by p6_rt_cache_alloc() and ip6_rt_pcpu_alloc().
Then the above newly added check is mainly to catch those cached dst
entries (created by ip6_rt_cached_alloc()). right?
And it is required because __ipv6_ifa_notify() -> ip6_del_rt() won't
take care of those cached dst entries.

Then I think I should wait for your patches to get merged before
submitting my patch?

Thanks.
Wei


On Sun, Aug 13, 2017 at 9:24 AM, David Ahern <dsahern@gmail.com> wrote:
> On 8/12/17 1:42 PM, Wei Wang wrote:
>> Hi Ido,
>>
>>>> -     if ((rt->dst.dev == dev || !dev) &&
>>>> +     if ((rt->dst.dev == dev || !dev ||
>>>> +          rt->rt6i_idev->dev == dev) &&
>>>
>>> Can you please explain why this line is needed? While host routes aren't
>>> removed from the FIB by rt6_ifdown() (when dst.dev goes down), they are
>>> removed later on in addrconf_ifdown().
>>>
>>
>> Yes.. Agree. But one difference is that if the route is removed from
>> addrconf_ifdown(), dst_dev_put() won't be called to release the
>> devices before doing dst_release(). It is OK if dst_release() sees the
>> refcnt on dst already drops to 0 and directly destroys the dst. But I
>> think it will cause problem if at the time, the dst is still held by
>> some other users because then the refcnt on the device going down will
>> not get released.
>> That's why I think we should remove the dst with either dst->dev ==
>> going down dev or rt6->rt6i_idev->dev == going down dev from the fib6
>> tree always because there, we always call dst_dev_put() to release the
>> device.
>>
>>> With your patch, if I check the return value of ip6_del_rt() in
>>> __ipv6_ifa_notify() I see that -ENONET is returned. Because the host
>>> route was already removed by rt6_ifdown(). When the line in question is
>>> removed from the patch I don't get the error anymore.
>>>
>>
>> Right. That is expected as the route is already removed from the tree.
>>
>>> Is it possible that in John's case the host route was correctly removed
>>> from the FIB and that the unreleased reference was due to a wrong check
>>> in ip6_dst_ifdown() (which you patched correctly AFAICT)?
>>>
>>
>> Yes. possible. But as I explained earlier, I still think we should
>> also remove routes with rt6->rt6i_idev->dev == going down dev from the
>> tree.
>
> Looking at my patch to move host routes from loopback to device with the
> address, I have this:
>
> @@ -2789,7 +2808,8 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
>         const struct arg_dev_net *adn = arg;
>         const struct net_device *dev = adn->dev;
>
> -       if ((rt->dst.dev == dev || !dev) &&
> +       if ((rt->dst.dev == dev || !dev ||
> +            (netdev_unregistering(dev) && rt->rt6i_idev->dev == dev)) &&
>             rt != adn->net->ipv6.ip6_null_entry &&
>             (rt->rt6i_nsiblings == 0 ||
>              (dev && netdev_unregistering(dev)) ||
>
>
