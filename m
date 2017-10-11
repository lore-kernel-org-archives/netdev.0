From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Wed, 11 Oct 2017 17:44:10 -0400
Message-ID: <CAF=yD-++Vn6UbDm5q7_wpwx90Wt-Yia+g4ju_cJ+rX34tt7JPw@mail.gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
 <20171009.205228.714368596112967819.davem@davemloft.net> <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
 <20171010.103918.358738948563291074.davem@davemloft.net> <CAF=yD-J+Abjka9PViEFE6OhKOWf65UK1do5prYboFC+m+Tv1wA@mail.gmail.com>
 <3ef92f5f-b242-a66a-860f-31da29216dc4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:38055 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750718AbdJKVov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:44:51 -0400
Received: by mail-oi0-f67.google.com with SMTP id t134so1598692oih.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:44:51 -0700 (PDT)
In-Reply-To: <3ef92f5f-b242-a66a-860f-31da29216dc4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 11:15 PM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B410=E6=9C=8811=E6=97=A5 03:11, Willem de Bruijn wrote:
>>
>> On Tue, Oct 10, 2017 at 1:39 PM, David Miller <davem@davemloft.net> wrot=
e:
>>>
>>> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
>>> Date: Tue, 10 Oct 2017 11:29:33 -0400
>>>
>>>> If there is a way to expose these stats through vhost_net directly,
>>>> instead of through tun, that may be better. But I did not see a
>>>> suitable interface. Perhaps debugfs.
>>>
>>> Please don't use debugfs, thank you :-)
>>
>> Okay. I'll take a look at tracing for on-demand measurement.
>
>
> This reminds me a past series that adding tracepoints to vhost/net[1]. It
> can count zero/datacopy independently and even contains a sample program =
to
> show the stats.

Interesting, thanks!

For occasional evaluation, we can also use a bpf kprobe for the time being:

  bpf_program =3D """
  #include <uapi/linux/ptrace.h>
  #include <bcc/proto.h>

  BPF_ARRAY(count, u64, 2);

  void inc_counter(struct pt_regs *ctx) {
      bool success;
      int key;
      u64 *val;

      success =3D PT_REGS_PARM2(ctx);
      key =3D success ? 0 : 1;
      val =3D count.lookup(&key);
      if (val)
          lock_xadd(val, 1);
  }
  """

  b =3D bcc.BPF(text=3Dbpf_program)
  b.attach_kprobe(event=3D"vhost_zerocopy_callback", fn_name=3D"inc_counter=
")

  time.sleep(5)

  print("vhost_zerocopy_callback: Y:%d N:%d" %
        (b["count"][ctypes.c_int(0)].value,
         b["count"][ctypes.c_int(1)].value))
