From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Sun, 21 Feb 2010 16:41:36 +0800
Message-ID: <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
References: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016364ec7a8dc7ddc048018480e
Cc: rusty@rustcorp.com.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: Dongdong Deng <dongdong.deng@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:52140 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab0BUIlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 03:41:37 -0500
In-Reply-To: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016364ec7a8dc7ddc048018480e
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 21, 2010 at 3:24 PM, Dongdong Deng
<dongdong.deng@windriver.com> wrote:
> The param_set_fn() function will get a parameter which is a NULL
> pointer when insmod module with params via following method:
>
> $insmod module.ko module_params
>
> BTW: the normal method usually as following format:
> $insmod module.ko module_params=3Dexample
>
> If the param_set_fn() function didn't check that parameter and used
> it directly, it could caused an OOPS due to NULL pointer dereference.
>
> The solution is simple:
> Just checking the parameter before using in param_set_fn().
>
> Example:
> int set_module_params(const char *val, struct kernel_param *kp)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*Checking the val parameter before using */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!val)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> }
> module_param_call(module_params, set_module_params, NULL, NULL, 0644);
>

Why not just checking all of them in the generic code?
How about my _untested_ patch below?

Thanks.

-----------

When a module parameter "foo" is not bool, we shouldn't accept arguments
like this "insmod ./foo.ko foo". However, currently only standard
->set functions
check this, several non-standard ->set functions ignore this, thus could ca=
use
NULL def oops.

Reported-by: Dongdong Deng <dongdong.deng@windriver.com>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---

--0016364ec7a8dc7ddc048018480e
Content-Type: text/plain; charset=US-ASCII;
	name="kernel-params_c-check-null-for-non-bool.diff"
Content-Disposition: attachment;
	filename="kernel-params_c-check-null-for-non-bool.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g5xle1v40

ZGlmZiAtLWdpdCBhL2tlcm5lbC9wYXJhbXMuYyBiL2tlcm5lbC9wYXJhbXMuYwppbmRleCBjZjFi
NjkxLi44NGExNDY2IDEwMDY0NAotLS0gYS9rZXJuZWwvcGFyYW1zLmMKKysrIGIva2VybmVsL3Bh
cmFtcy5jCkBAIC01OSw2ICs1OSw4IEBAIHN0YXRpYyBpbnQgcGFyc2Vfb25lKGNoYXIgKnBhcmFt
LAogCS8qIEZpbmQgcGFyYW1ldGVyICovCiAJZm9yIChpID0gMDsgaSA8IG51bV9wYXJhbXM7IGkr
KykgewogCQlpZiAocGFyYW1lcShwYXJhbSwgcGFyYW1zW2ldLm5hbWUpKSB7CisJCQlpZiAoKCFw
YXJhbXNbaV0uZmxhZ3MgJiBLUEFSQU1fSVNCT09MKSAmJiAhdmFsKQorCQkJCXJldHVybiAtRUlO
VkFMOwogCQkJREVCVUdQKCJUaGV5IGFyZSBlcXVhbCEgIENhbGxpbmcgJXBcbiIsCiAJCQkgICAg
ICAgcGFyYW1zW2ldLnNldCk7CiAJCQlyZXR1cm4gcGFyYW1zW2ldLnNldCh2YWwsICZwYXJhbXNb
aV0pOwo=
--0016364ec7a8dc7ddc048018480e--
