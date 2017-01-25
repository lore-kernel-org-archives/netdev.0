From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loopback device reference count leakage
Date: Wed, 25 Jan 2017 11:50:25 -0800
Message-ID: <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1146ee9e7346570546f08cfa
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kaiwen Xu <kevin@kevxu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33384 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751446AbdAYTuw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:50:52 -0500
Received: by mail-wm0-f65.google.com with SMTP id r144so44909101wme.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 11:50:52 -0800 (PST)
In-Reply-To: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1146ee9e7346570546f08cfa
Content-Type: text/plain; charset=UTF-8

Hello,

On Mon, Jan 23, 2017 at 9:17 PM, Kaiwen Xu <kevin@kevxu.net> wrote:
> Hi netdev folks,
>
> I am currently experiencing an issue related with the loopback during
> network devices shutdown inside a network namespace, which mainfested as
>
>     unregister_netdevice: waiting for lo to become free. Usage count = 1
>
> showing up every 10 seconds or so in the kernel log. It eventually
> causes a deadlock on new network namespace creation.

It is at least the 3rd time I saw this bug report. ;)

>
> When I was trying to debug the issue, I tested from latest kernel 4.10-rc
> back to 3.19, which all can be reproduced on. I also tried to disable
> IPv6, which doesn't help either.
>
> So I tried to patch the kernel with following change to add addtional
> logging message for dev_put() and dev_hold().
>
>     https://lkml.org/lkml/2008/7/20/5
>
> Here are all the dev_put/hold() calls for the loopback device inside a
> namespace from creation to shutdown, when the issue occurs.

Excellent debugging!

>From your debugging output, the dst_ifdown() looks suspicious to me,
it seems to be the reason why we miss one dev_put().


> Could you please give me some pointers why this issue could occur? I can
> also provide addtional information if needed.
>

Do you mind to try the attached patch (compile only)? Try it with your
debugging printk's in case it doesn't fix this bug, but it should make some
difference at least.

Thanks!

--001a1146ee9e7346570546f08cfa
Content-Type: text/plain; charset=US-ASCII; name="dst-loopback.diff"
Content-Disposition: attachment; filename="dst-loopback.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iydd6i900

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2RzdC5jIGIvbmV0L2NvcmUvZHN0LmMKaW5kZXggYjVjYmJl
MC4uOTkxODRiYSAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZHN0LmMKKysrIGIvbmV0L2NvcmUvZHN0
LmMKQEAgLTQ0MSw4ICs0NDEsMTIgQEAgc3RhdGljIHZvaWQgZHN0X2lmZG93bihzdHJ1Y3QgZHN0
X2VudHJ5ICpkc3QsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsCiAJCWRzdC0+aW5wdXQgPSBkc3Rf
ZGlzY2FyZDsKIAkJZHN0LT5vdXRwdXQgPSBkc3RfZGlzY2FyZF9vdXQ7CiAJfSBlbHNlIHsKLQkJ
ZHN0LT5kZXYgPSBkZXZfbmV0KGRzdC0+ZGV2KS0+bG9vcGJhY2tfZGV2OwotCQlkZXZfaG9sZChk
c3QtPmRldik7CisJCWlmIChkc3QtPmRldiAhPSBkZXZfbmV0KGRzdC0+ZGV2KS0+bG9vcGJhY2tf
ZGV2KSB7CisJCQlkc3QtPmRldiA9IGRldl9uZXQoZHN0LT5kZXYpLT5sb29wYmFja19kZXY7CisJ
CQlkZXZfaG9sZChkc3QtPmRldik7CisJCX0gZWxzZSB7CisJCQlkc3QtPmRldiA9IE5VTEw7CisJ
CX0KIAkJZGV2X3B1dChkZXYpOwogCX0KIH0K
--001a1146ee9e7346570546f08cfa--
