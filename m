From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf: kernel BUG in htab_elem_free
Date: Thu, 03 Nov 2016 17:36:06 +0100
Message-ID: <581B6776.3060908@iogearbox.net>
References: <CACT4Y+YUWArFF=6VGJvzTEr7C7E323gOCno7fyw36xBYC7MH=w@mail.gmail.com> <CACT4Y+a2W++HSgMXqFSqNDuexudHf0buZqtt7pBHrAKz57pFeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+a2W++HSgMXqFSqNDuexudHf0buZqtt7pBHrAKz57pFeQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2016 03:15 PM, Dmitry Vyukov wrote:
> On Wed, Nov 2, 2016 at 11:14 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Here we go.
>>
>> The following program triggers kernel BUG in htab_elem_free.
>> On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
>> Run as "while true; do ./a.out; done".

This one fixes it for me. Could you check it from your side as well?
I'll submit an official fix then.

Thanks a lot for the catch!
Daniel

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 570eeca..ad1bc67 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -687,7 +687,8 @@ static void delete_all_elements(struct bpf_htab *htab)

  		hlist_for_each_entry_safe(l, n, head, hash_node) {
  			hlist_del_rcu(&l->hash_node);
-			htab_elem_free(htab, l);
+			if (l->state != HTAB_EXTRA_ELEM_USED)
+				htab_elem_free(htab, l);
  		}
  	}
  }
