From: Nivedita Singhvi <niv@us.ibm.com>
Subject: TCP hang in timewait processing
Date: Sat, 27 Mar 2004 15:27:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40660DF7.9090806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@oss.sgi.com>, Elizabeth Kon <bkon@us.ibm.com>,
        jgrimm@us.ibm.com, jgarvey@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

We're investigating a hang in TCP that a clustered node
is running into, and I'd appreciate any help whatsoever
on this...

System is running SLES8 + patches (including latest
fixes in timewait stuff) - but is pretty equivalent
to mainline 2.4 kernel from what I can tell.
Problem is reproducible, takes anywhere from several
hours to a day.

The hang occurs due to the while in tcp_twkill going
into an infinite loop:

while((tw =3D tcp_tw_death_row[tcp_tw_death_row_slot]) !=3D NULL) {
	tcp_tw_death_row[tcp_tw_death_row_slot] =3D tw->next_death;
	if (tw->next_death)
		tw->next_death->pprev_death =3D tw->pprev_death;
	tw->pprev_death =3D NULL;
	spin_unlock(&tw_death_lock);

	tcp_timewait_kill(tw);
	tcp_tw_put(tw);

	killed++;

	spin_lock(&tw_death_lock);
}

Thanks to some neat detective work by Beth Kon and Joe
Garvey, the culprit seems to be a tw node pointing to
itself. See attached note from Beth at end.

This is possible if a tcp_tw_bucket is freed prematurely
before being taken off the death list. If the node is
at the head of the list, and is freed and then later
reallocated in tcp_time_wait() and reinserted into the
list, (now linked to a new sk) it will end up pointing at
itself. [There might be other ways to end up like this,
but I'm not seeing them]

We come into tcp_tw_schedule() (which puts it into the
death list) with pprev_death cleared by tcp_time_wait().

tcp_tw_schedule() {

	if (tw->pprev_death) {
		...
	} else
		atomic_inc(&tw->refcnt);

	...

	if((tw->next_death =3D *tpp) !=3D NULL)
		(*tpp)->pprev_death =3D &tw->next_death;
	*tpp =3D tw;
	tw->pprev_death =3D tpp;
									=09
If tw is at the head of the list, (*tpp =3D=3D tw), then
we just created a loop of tw->next_death pointing at tw.
If tw is in other places on the death list, we could
potentially have Y-shaped chains and other garbage...

Does that seem correct, or am I barking up the wrong
tree here?

Just checking at this point for a node pointing to
itself is rather late - the damage has been done in
losing the original linkages from the tcp_tw_bucket
to the other structures which we need to remove as
well, so as to not cause a further mess in the hash
table and death list pointers.

So the question is, is there any path that leads to
us erroneously freeing tcp_tw_bucket without taking it
off the death list?

I've been looking at the tw refcount manipulation
and am trying to identify any  possible gratuitous
tcp_tw_put() calls, but haven't successfully isolated
any one yet.

Any ideas, pointers would be very much appreciated!

thanks,
Nivedita

---
 From Beth Kon:
I see what is going on here... not sure how it got to this state.

Joe Garvey did excellent work gathering kdb info (and
graciously taught me a lot as he went along) and confirming that the
while loop in tcp_twkill is in an infinite loop.

Here is the code in tcp_twkill that is in an infinite loop:

while((tw =3D tcp_tw_death_row[tcp_tw_death_row_slot]) !=3D NULL) {
                 tcp_tw_death_row[tcp_tw_death_row_slot] =3D tw->next_dea=
th;
                 if (tw->next_death)
                         tw->next_death->pprev_death =3D tw->pprev_death;
                 tw->pprev_death =3D NULL;
                 spin_unlock(&tw_death_lock);

                 tcp_timewait_kill(tw);
                 tcp_tw_put(tw);

                 killed++;

                 spin_lock(&tw_death_lock);
         }
Using the data Joe gathered, here is what I see...

[0]kdb> rd
eax =3D 0x00000001 ebx =3D 0xc50a7840 ecx =3D 0xdf615478 edx =3D 0x000000=
01
esi =3D 0x061c3332 edi =3D 0x00000000 esp =3D 0xc03e7f10 eip =3D 0xc02be9=
50
ebp =3D 0x00000000 xss =3D 0xc02e0018 xcs =3D 0x00000010 eflags =3D 0x000=
00282
xds =3D 0x00000018 xes =3D 0x00000018 origeax =3D 0xffffffff &regs =3D 0x=
c03e7edc

In the above register dump, the pointer to the tw being handled in the
tcp_twkill loop is in ebx.

The contents of the tw struct (annotated by me) are:

[0]kdb> mds %ebx tw
0xc50a7840 260f3c09   .<.&    daddr
0xc50a7844 6d0f3c09   .<.m    rcv_saddr
0xc50a7848 8200a3e5   =E5=A3..    dport, num
0xc50a784c 00000000   ....    bound_dev_if
0xc50a7850 00000000   ....    next
0xc50a7854 00000000   ....    pprev
0xc50a7858 00000000   ....    bindnext
0xc50a785c c26dcbc8   =C8=CBm=C2    bind_pprev
[0]kdb>
0xc50a7860 00820506   ....    state, substate, sport
0xc50a7864 00000002   ....    family
0xc50a7868 f9e3ccd0   =D0=CC=E3=F9   refcnt
0xc50a786c 00002a8f   .*..   hashent
0xc50a7870 00001770   p...   timeout
0xc50a7874 d4ad3cee   =EE<=AD=D4   rcv_next
0xc50a7878 878fe09e   .=E0..   send_next
0xc50a787c 000016d0   =D0...   rcv_wnd
[0]kdb>
0xc50a7880 00000000   ....    ts_recent
0xc50a7884 00000000   ....    ts_recent_stamp
0xc50a7888 000353c1   =C1S..    ttd
0xc50a788c 00000000   ....    tb
0xc50a7890 c50a7840   @x.=C5    next_death
0xc50a7894 00000000   ....    pprev_death
0xc50a7898 00000000   ....
0xc50a789c 00000000   ....

The above shows that next_death in the structure =3D=3D ebx. Which means =
this
element of the linked list is pointing to itself. So it in an infinite lo=
op.
Assuming this is the last element on the linked list, next_death should b=
e null.
