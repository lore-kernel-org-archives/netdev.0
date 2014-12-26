From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/27] Use setup_timer
Date: Fri, 26 Dec 2014 15:35:31 +0100
Message-ID: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, linux-usb@vger.kernel.org
To: wil6210@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches group a call to init_timer and initialization of the function
and data fields into a call to setup_timer.  Is there is no initialization
of the data field before add_timer is called, the the data value is set to
0UL.  If the data value has a cast to something other than unsigned long,
it is changes to a cast to unsigned long, which is the type of the data
field.

The semantic patch that performs this change is shown below
(http://coccinelle.lip6.fr/).  This semantic patch is fairly restrictive on
what appears between the init_timer call and the two field initializations,
to ensure that the there is no code that the initializations depend on.

// <smpl>
@@
expression t,d,f,e1,e2;
identifier x1,x2;
statement S1,S2;
@@

(
-t.data = d;
|
-t.function = f;
|
-init_timer(&t);
+setup_timer(&t,f,d);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,d);
)
<... when != S1
t.x1 = e1;
...>
(
-t.data = d;
|
-t.function = f;
|
-init_timer(&t);
+setup_timer(&t,f,d);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,d);
)
<... when != S2
t.x2 = e2;
...>
(
-t.data = d;
|
-t.function = f;
|
-init_timer(&t);
+setup_timer(&t,f,d);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,d);
)

// ----------------------

@@
expression t,d,f,e1,e2;
identifier x1,x2;
statement S1,S2;
@@

(
-t->data = d;
|
-t->function = f;
|
-init_timer(t);
+setup_timer(t,f,d);
|
-init_timer_on_stack(t);
+setup_timer_on_stack(t,f,d);
)
<... when != S1
t->x1 = e1;
...>
(
-t->data = d;
|
-t->function = f;
|
-init_timer(t);
+setup_timer(t,f,d);
|
-init_timer_on_stack(t);
+setup_timer_on_stack(t,f,d);
)
<... when != S2
t->x2 = e2;
...>
(
-t->data = d;
|
-t->function = f;
|
-init_timer(t);
+setup_timer(t,f,d);
|
-init_timer_on_stack(t);
+setup_timer_on_stack(t,f,d);
)

// ---------------------------------------------------------------------
// no initialization of data field

@@
expression t,d1,d2,f;
@@

(
-init_timer(&t);
+setup_timer(&t,f,0UL);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,0UL);
)
... when != t.data = d1;
-t.function = f;
... when != t.data = d2;
add_timer(&t);

@@
expression t,d,f,fn;
type T;
@@

-t.function = f;
... when != t.data
    when != fn(...,(T)t,...)
(
-init_timer(&t);
+setup_timer(&t,f,d);
|
-init_timer_on_stack(&t);
+setup_timer_on_stack(&t,f,0UL);
)
... when != t.data = d;
add_timer(&t);

// ----------------------

@@
expression t,d1,d2,f;
@@

(
-init_timer(t);
+setup_timer(t,f,0UL);
|
-init_timer_on_stack(t);
+setup_timer_on_stack(t,f,0UL);
)
... when != t->data = d1;
-t->function = f;
... when != t->data = d2;
add_timer(t);

@@
expression t,d,f,fn;
type T;
@@

-t->function = f;
... when != t.data
    when != fn(...,(T)t,...)
(
-init_timer(t);
+setup_timer(t,f,d);
|
-init_timer_on_stack(t);
+setup_timer_on_stack(t,f,0UL);
)
... when != t->data = d;
add_timer(t);

// ---------------------------------------------------------------------
// change data field type

@@
expression d;
type T;
@@

(
setup_timer
|
setup_timer_on_stack
)
 (...,
(
  (unsigned long)d
|
- (T)
+ (unsigned long)
  d
)
 )
// </smpl>
