From: Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Fri, 11 Aug 2017 17:10:02 -0700
Message-ID: <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com> <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a114dd95a563b4e05568340c8"
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux USB List <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--001a114dd95a563b4e05568340c8
Content-Type: text/plain; charset="UTF-8"

> If after Cong's fix, the issue still happens, could you help try the
> patch attached and collect all logs when you try the reproduce the
> issue? It would be great to have logs for both success case and the
> failure case.
>
> Thanks so much for your help.
>

I think we have a potential fix for this issue.
Martin and I found that when addrconf_dst_alloc() creates a rt6, it is
possible that rt6->dst.dev points to loopback device while
rt6->rt6i_idev->dev points to a real device.
When the real device goes down, the current fib6 clean up code only
checks for rt6->dst.dev and assumes rt6->rt6i_idev->dev is the same.
That leaves unreleased refcnt on the real device if rt6->dst.dev
points to loopback dev.

The attached potential fix is tested by Martin and made sure it fixes his issue.

John,
It will be great if you can also give it a try and see if it fixes the
issue on your side before I submit an official patch.

Thanks very much for the help from everyone.

Wei

On Fri, Aug 11, 2017 at 10:25 AM, Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Aug 11, 2017 at 9:48 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Hi,
>>
>> On Thu, Aug 10, 2017 at 11:12 AM, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>> On Wed, Aug 9, 2017 at 10:41 PM, Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>>> Hi John,
>>>>
>>>> Is it possible to try the attached patch?
>>>
>>> Thanks so much for the quick turn around!
>>>
>>> So I dropped all the reverts you suggested, and applied this one
>>> against 4.13-rc4, but I'm still seeing the problematic behavior.
>>
>> Does the following one-line fix make a difference?
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index a640fbcba15d..c145a35763a0 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -141,7 +141,7 @@ static void rt6_uncached_list_del(struct rt6_info *rt)
>>                 struct uncached_list *ul = rt->rt6i_uncached_list;
>>
>>                 spin_lock_bh(&ul->lock);
>> -               list_del(&rt->rt6i_uncached);
>> +               list_del_init(&rt->rt6i_uncached);
>>                 spin_unlock_bh(&ul->lock);
>>         }
>>  }
>
>
> Thanks a lot Cong for proposing this fix.
>
> For the last few days, John has been helping me running debug image
> and we found out that the leaked dst is probably in addrconf.c.
> Martin and I are looking through the code and trying to put more debugs.
>
> John,
>
> If after Cong's fix, the issue still happens, could you help try the
> patch attached and collect all logs when you try the reproduce the
> issue? It would be great to have logs for both success case and the
> failure case.
>
> Thanks so much for your help.
>
> Wei

--001a114dd95a563b4e05568340c8
Content-Type: text/x-patch; charset="US-ASCII";
	name="0001-potential-fix-for-unregister_netdevice.patch"
Content-Disposition: attachment;
	filename="0001-potential-fix-for-unregister_netdevice.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j68jh6mf1

RnJvbSAyZDg4NjE4MDhjMjAyOTAxM2Y2YjZlODYxMjBiYTY5MDIzMjkxNDViIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBXZWkgV2FuZyA8d2Vpd2FuQGdvb2dsZS5jb20+CkRhdGU6IEZy
aSwgMTEgQXVnIDIwMTcgMTY6MzY6MDQgLTA3MDAKU3ViamVjdDogW1BBVENIIDEvMl0gcG90ZW50
aWFsIGZpeCBmb3IgdW5yZWdpc3Rlcl9uZXRkZXZpY2UoKQoKQ2hhbmdlLUlkOiBJNWQ1ZjZmN2E3
YWQwZjVkZDc2OWYzMzQ4N2RiMTdmZjI1NzBkNTJlYQotLS0KIG5ldC9pcHY2L3JvdXRlLmMgfCAx
NyArKysrKysrKy0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDggaW5zZXJ0aW9ucygrKSwgOSBk
ZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvaXB2Ni9yb3V0ZS5jIGIvbmV0L2lwdjYvcm91
dGUuYwppbmRleCA0ZDMwYzk2YTgxOWQuLjEwNTkyMjkwMzkzMiAxMDA2NDQKLS0tIGEvbmV0L2lw
djYvcm91dGUuYworKysgYi9uZXQvaXB2Ni9yb3V0ZS5jCkBAIC00MTcsMTQgKzQxNywxMiBAQCBz
dGF0aWMgdm9pZCBpcDZfZHN0X2lmZG93bihzdHJ1Y3QgZHN0X2VudHJ5ICpkc3QsIHN0cnVjdCBu
ZXRfZGV2aWNlICpkZXYsCiAJc3RydWN0IG5ldF9kZXZpY2UgKmxvb3BiYWNrX2RldiA9CiAJCWRl
dl9uZXQoZGV2KS0+bG9vcGJhY2tfZGV2OwogCi0JaWYgKGRldiAhPSBsb29wYmFja19kZXYpIHsK
LQkJaWYgKGlkZXYgJiYgaWRldi0+ZGV2ID09IGRldikgewotCQkJc3RydWN0IGluZXQ2X2RldiAq
bG9vcGJhY2tfaWRldiA9Ci0JCQkJaW42X2Rldl9nZXQobG9vcGJhY2tfZGV2KTsKLQkJCWlmIChs
b29wYmFja19pZGV2KSB7Ci0JCQkJcnQtPnJ0NmlfaWRldiA9IGxvb3BiYWNrX2lkZXY7Ci0JCQkJ
aW42X2Rldl9wdXQoaWRldik7Ci0JCQl9CisJaWYgKGlkZXYgJiYgaWRldi0+ZGV2ICE9IGxvb3Bi
YWNrX2RldikgeworCQlzdHJ1Y3QgaW5ldDZfZGV2ICpsb29wYmFja19pZGV2ID0KKwkJCWluNl9k
ZXZfZ2V0KGxvb3BiYWNrX2Rldik7CisJCWlmIChsb29wYmFja19pZGV2KSB7CisJCQlydC0+cnQ2
aV9pZGV2ID0gbG9vcGJhY2tfaWRldjsKKwkJCWluNl9kZXZfcHV0KGlkZXYpOwogCQl9CiAJfQog
fQpAQCAtMjc4OSw3ICsyNzg3LDggQEAgc3RhdGljIGludCBmaWI2X2lmZG93bihzdHJ1Y3QgcnQ2
X2luZm8gKnJ0LCB2b2lkICphcmcpCiAJY29uc3Qgc3RydWN0IGFyZ19kZXZfbmV0ICphZG4gPSBh
cmc7CiAJY29uc3Qgc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IGFkbi0+ZGV2OwogCi0JaWYgKChy
dC0+ZHN0LmRldiA9PSBkZXYgfHwgIWRldikgJiYKKwlpZiAoKHJ0LT5kc3QuZGV2ID09IGRldiB8
fCAhZGV2IHx8CisJICAgICBydC0+cnQ2aV9pZGV2LT5kZXYgPT0gZGV2KSAmJgogCSAgICBydCAh
PSBhZG4tPm5ldC0+aXB2Ni5pcDZfbnVsbF9lbnRyeSAmJgogCSAgICAocnQtPnJ0NmlfbnNpYmxp
bmdzID09IDAgfHwKIAkgICAgIChkZXYgJiYgbmV0ZGV2X3VucmVnaXN0ZXJpbmcoZGV2KSkgfHwK
LS0gCjIuMTQuMC40MzQuZzk4MDk2ZmQ3YTgtZ29vZwoK
--001a114dd95a563b4e05568340c8--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
